extends Node3D

@onready var enemy : PackedScene = preload("res://Mobs/ufo.tscn")
@onready var cannon : PackedScene = preload("res://Scenes/Towers/cannon-exp.tscn")
@onready var blaster : PackedScene = preload("res://Scenes/Towers/blaster-exp.tscn")
@onready var sniper : PackedScene = preload("res://Scenes/Towers/sniper-exp.tscn")

@onready var cam : Camera3D = $Camera3D
@onready var indicator : MeshInstance3D = $BuildIndicator
@onready var sound_effects: AudioStreamPlayer2D = $SoundEffects
@onready var music : AudioStreamPlayer2D = $Music

var enemies_to_spawn : int = 0
var can_spawn : bool = true
var in_build_menu : bool = false
var wave_on_going : bool = false
var boss_wave : bool = false
var in_options : bool = false

func _ready() -> void:
	music.play_sound_effect_from_lib("music")

func _process(delta: float) -> void:
	handle_player_controls()
	handle_ui()
	game_manager()
	
func handle_player_controls() -> void:
	if Input.is_action_just_pressed("options"):
		in_options = true
		get_tree().paused = true
	var space_state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	
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
					in_build_menu = true
					
			else:
				indicator.set_surface_override_material(0, load("res://Materials/red.tres"))
		else:
			indicator.visible = false

func game_manager() -> void:
	if Global.health <= 0:
		game_over()
	
	if boss_wave and enemies_to_spawn == 1 and can_spawn:
		var boss = enemy.instantiate()
		var character : CharacterBody3D = boss.get_child(0)
		character.create_boss()
		$Path.add_child(boss)
		
		enemies_to_spawn -= 1
		Global.enemies_alive += 1
		can_spawn = false
	
	elif enemies_to_spawn > 0 and can_spawn:
		$SpawnTimer.start()
		var temp_enemy = enemy.instantiate()
		$Path.add_child(temp_enemy)
		
		enemies_to_spawn -= 1
		Global.enemies_alive += 1
		can_spawn = false
	
	if Global.enemies_alive > 0:
		wave_on_going = true
	else:
		wave_on_going = false

func buy_tower(cost : int, scene : PackedScene) -> void:
	if Global.money >= cost:
		in_build_menu = false
		Global.money -= cost
		var temp_tower : StaticBody3D = scene.instantiate()
		add_child(temp_tower)
		temp_tower.global_position = indicator.global_position
		sound_effects.play_sound_effect_from_lib("place")

func handle_ui() -> void:
	$CanvasLayer/UI/ShopPanel.visible = in_build_menu
	$CanvasLayer/UI/NextWave.visible = not wave_on_going
	$Map/TowerRoundSampleF/HealthBar3D.update(Global.health)
	$CanvasLayer/UI/Gold.text = "Gold: " + str(Global.money)
	$CanvasLayer/UI/Wave.text = "Wave: " + str(Global.wave)
	$CanvasLayer/UI/BossWave.visible = boss_wave
	$CanvasLayer/UI/OptionsPanel.visible = in_options

func _on_spawn_timer_timeout() -> void:
	can_spawn = true

func game_over() -> void:
	$CanvasLayer/UI/GameOverPanel.visible = true

func _on_cannon_button_pressed() -> void:
	buy_tower(250, cannon)

func _on_blaster_button_pressed() -> void:
	buy_tower(300, blaster)
	
func _on_sniper_button_pressed() -> void:
	buy_tower(300, sniper)

func _on_cancel_button_pressed() -> void:
	in_build_menu = false

func _on_next_wave_pressed() -> void:
	sound_effects.play_sound_effect_from_lib("sinister")
	Global.wave += 1
	boss_wave = Global.wave % 5 == 0
	if boss_wave:
		enemies_to_spawn = 1
	else:
		enemies_to_spawn = Global.wave * 3
	can_spawn = true


func _on_play_again_button_pressed() -> void:
	$CanvasLayer/UI/GameOverPanel.visible = false
	Global.reset()
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_close_button_pressed() -> void:
	get_tree().paused = false
	in_options = false
