extends Control

@onready var enemy : PackedScene = preload("res://Mobs/ufo.tscn")
@onready var cannon : PackedScene = preload("res://Scenes/Towers/cannon-exp.tscn")
@onready var blaster : PackedScene = preload("res://Scenes/Towers/blaster-exp.tscn")
@onready var sniper : PackedScene = preload("res://Scenes/Towers/sniper-exp.tscn")
@onready var main_menu : Panel = $"CanvasLayer/UI/Main Menu"
@onready var main_node : Node3D = $Main3D
@onready var indicator : MeshInstance3D = $Main3D/BuildIndicator
@onready var sound_effects: AudioStreamPlayer2D = $SoundEffects

var in_main_menu : bool = true
var in_build_menu : bool = false
var wave_on_going : bool = false
var boss_wave : bool = false
var in_pause : bool = false
var enemies_to_spawn : int = 0
var can_spawn : bool = true
var game_over : bool = false
var selected_collider: CollisionObject3D = null

func reset_ui() -> void:
	in_main_menu = true
	in_build_menu = false
	wave_on_going = false
	boss_wave = false
	in_pause = false
	enemies_to_spawn = 0
	can_spawn = true
	game_over = false
	selected_collider = null

func handle_ui() -> void:
	$CanvasLayer/UI/ShopPanel.visible = in_build_menu
	$CanvasLayer/UI/NextWave.visible = not wave_on_going and not in_main_menu
	$CanvasLayer/UI/Gold.visible = not in_main_menu
	$CanvasLayer/UI/Gold.text = "Gold: " + str(Global.money)
	$CanvasLayer/UI/Wave.visible = not in_main_menu
	$CanvasLayer/UI/Wave.text = "Wave: " + str(Global.wave)
	$CanvasLayer/UI/BossWave.visible = boss_wave
	$CanvasLayer/UI/PausePanel.visible = in_pause
	$CanvasLayer/UI/GameOverPanel.visible = game_over

func handle_player_controls() -> void:
	if in_main_menu or in_pause:
		return
	var current_level : Node3D = main_node.get_node("World")
	if Input.is_action_just_pressed("options"):
		in_pause = true
		get_tree().paused = true
	
	var space_state : PhysicsDirectSpaceState3D = current_level.get_world_3d().direct_space_state
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	
	var cam:Camera3D = current_level.get_node("Camera3D")
	var origin : Vector3 = cam.project_ray_origin(mouse_pos)
	var end : Vector3 = origin + cam.project_ray_normal(mouse_pos) * 100
	var ray : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
	
	ray.collide_with_bodies = true
	
	var ray_result : Dictionary = space_state.intersect_ray(ray)
	if not in_build_menu:
		if ray_result.size() > 0:
			indicator.visible = true
			var collider : CollisionObject3D = ray_result.get("collider")
			
			indicator.global_position = collider.global_position + Vector3(0, 0.2, 0)
			
			if collider.is_in_group("Empty"):
				indicator.set_surface_override_material(0, load("res://Materials/green.tres"))
				if Input.is_action_just_pressed("interact"):
					selected_collider = collider
					in_build_menu = true
					
			elif collider.is_in_group("Tower"):
				indicator.visible = false
			else:
				indicator.set_surface_override_material(0, load("res://Materials/red.tres"))
		else:
			indicator.visible = false

func _process(_delta: float) -> void:
	handle_ui()
	handle_player_controls()
	game_manager()

func game_manager() -> void:
	if Global.health <= 0:
		game_over = true
	
	if boss_wave and enemies_to_spawn == 1 and can_spawn:
		var boss = enemy.instantiate()
		var character : CharacterBody3D = boss.get_child(0)
		character.create_boss()
		main_node.get_node("World").get_node("Path").add_child(boss)
		
		enemies_to_spawn -= 1
		Global.enemies_alive += 1
		can_spawn = false
	
	elif enemies_to_spawn > 0 and can_spawn:
		main_node.get_node("SpawnTimer").start()
		var temp_enemy = enemy.instantiate()
		main_node.get_node("World").get_node("Path").add_child(temp_enemy)
		
		enemies_to_spawn -= 1
		Global.enemies_alive += 1
		can_spawn = false
	
	if Global.enemies_alive > 0:
		wave_on_going = true
	else:
		wave_on_going = false

func buy_tower(cost : int, scene : PackedScene) -> void:
	if Global.money >= cost:
		selected_collider.remove_from_group("Empty")
		selected_collider.add_to_group("Tower")
		in_build_menu = false
		Global.money -= cost
		var temp_tower : StaticBody3D = scene.instantiate()
		add_child(temp_tower)
		temp_tower.global_position = indicator.global_position
		sound_effects.play_sound_effect_from_lib("place")

### Signals

func _on_next_wave_pressed() -> void:
	sound_effects.play_sound_effect_from_lib("sinister")
	Global.wave += 1
	boss_wave = Global.wave % 2 == 0
	if boss_wave:
		enemies_to_spawn = 1
	else:
		enemies_to_spawn = Global.wave * 3
	can_spawn = true

func _on_spawn_timer_timeout() -> void:
	can_spawn = true

func _on_cannon_button_pressed() -> void:
	buy_tower(250, cannon)

func _on_blaster_button_pressed() -> void:
	buy_tower(300, blaster)

func _on_sniper_button_pressed() -> void:
	buy_tower(300, sniper)

func _on_cancel_button_pressed() -> void:
	in_build_menu = false

func _on_return_button_pressed() -> void:
	get_tree().paused = false
	in_pause = false

func _on_quit_game_pressed() -> void:
	# Unpause the tree
	get_tree().paused = false
	var world_node = main_node.get_node("World")
	world_node.queue_free()
	# Fix UI
	reset_ui()
	# Update stats
	Global.reset()
	main_menu.visible = true
	get_tree().reload_current_scene()
