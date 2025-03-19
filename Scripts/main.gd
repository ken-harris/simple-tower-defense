extends Node3D

@onready var enemy : PackedScene = preload("res://Mobs/ufo.tscn")
@onready var cannon : PackedScene = preload("res://Scenes/Towers/cannon2-exp.tscn")
@onready var blaster : PackedScene = preload("res://Scenes/Towers/blaster-exp.tscn")
@onready var sniper : PackedScene = preload("res://Scenes/Towers/sniper-exp.tscn")
@onready var ice:PackedScene = preload("res://Scenes/Towers/ice-exp.tscn")
@onready var flame:PackedScene = preload("res://Scenes/Towers/flame-exp.tscn")

@onready var main_menu : Panel = $"CanvasLayer/UI/Main Menu"
@onready var stat_panel: Panel = $"CanvasLayer/UI/StatsPanel"
@onready var main_node : Node3D = $Main3D
@onready var indicator : MeshInstance3D = $Main3D/BuildIndicator
@onready var sound_effects: AudioStreamPlayer2D = $SoundEffects
@onready var debug_text: Label = $CanvasLayer/UI/Debug
@onready var complete_timer : Timer = $CompleteTimer

var in_main_menu : bool = true
var in_build_menu : bool = false
var in_tower_stats: bool = false
var in_pause : bool = false
var game_over : bool = false
var camera_mode_enabled:bool = false
var selected_collider: CollisionObject3D = null
var selected_tower:Tower = null
var waiting_complete:bool = false

func reset_ui() -> void:
	in_main_menu = true
	in_build_menu = false
	in_tower_stats = false
	in_pause = false
	game_over = false
	selected_collider = null
	selected_tower = null
	waiting_complete = false

func handle_ui() -> void:
	$CanvasLayer/UI/ShopPanel.visible = in_build_menu
	$CanvasLayer/UI/StatsPanel.visible = in_tower_stats
	$CanvasLayer/UI/NextWave.visible = not Global.wave_ongoing and not Global.wave == Global.total_waves
	$CanvasLayer/UI/EnemiesRemain.visible = not in_main_menu and not (not Global.wave_ongoing and Global.enemies_alive == 0)
	$CanvasLayer/UI/EnemiesRemain.text = "Remain: " + str(Global.wave_enemies_remain)
	$CanvasLayer/UI/Gold.visible = not in_main_menu
	$CanvasLayer/UI/Gold.text = "Gold: " + str(Global.money)
	$CanvasLayer/UI/Wave.visible = not in_main_menu
	$CanvasLayer/UI/Wave.text = "Wave: " + str(Global.wave) + " / " + str(Global.total_waves)
	#$CanvasLayer/UI/BossWave.visible = boss_wave
	$CanvasLayer/UI/PausePanel.visible = in_pause
	$CanvasLayer/UI/GameOverPanel.visible = game_over
	$CanvasLayer/UI/GameCompletePanel.visible = Global.game_complete
	$CanvasLayer/UI/CameraButton.visible = not in_main_menu and not in_build_menu and not in_pause and not camera_mode_enabled and not in_tower_stats
	$CanvasLayer/UI/CameraInstructions.visible = camera_mode_enabled
	$CanvasLayer/UI/Debug.visible = not in_main_menu and not in_pause and not in_build_menu

func handle_player_controls() -> void:
	if in_main_menu or in_pause or in_tower_stats:
		return
	var current_level : Node3D = main_node.get_node("World")
	var player:CharacterBody3D = current_level.get_node("Player")
	var cam:Camera3D = player.get_node("Camera3D")
	
	if Input.is_action_just_pressed("options") and not camera_mode_enabled:
		in_pause = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
	elif Input.is_action_just_pressed("options") and camera_mode_enabled:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		player.camera_selected()
		camera_mode_enabled = false
	
	if camera_mode_enabled:
		return
	
	var space_state : PhysicsDirectSpaceState3D = current_level.get_world_3d().direct_space_state
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
			
			if collider is Tower:
				indicator.visible = false
				if Input.is_action_just_pressed("interact"):
					selected_tower = collider
					debug_text.text = collider.name
					var tower_data = collider.select_tower()
					in_tower_stats = true
					return
			
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
	
	# Checks if you have completed the selected level
	if not in_main_menu and \
		Global.wave == Global.total_waves \
		and not Global.wave_ongoing \
		and not Global.game_complete \
		and Global.enemies_alive == 0 \
		and not waiting_complete:
		waiting_complete = true
		complete_timer.start()
		print("Complete... Waiting....")

func buy_tower(cost : int, scene : PackedScene) -> void:
	if Global.money >= cost:
		selected_collider.remove_from_group("Empty")
		#selected_collider.add_to_group("Tower")
		in_build_menu = false
		Global.money -= cost
		var temp_tower : StaticBody3D = scene.instantiate()
		temp_tower.add_to_group("Tower", true)
		add_child(temp_tower)
		temp_tower.global_position = indicator.global_position
		sound_effects.play_sound_effect_from_lib("place")

### Signals

func _on_next_wave_pressed() -> void:
	sound_effects.play_sound_effect_from_lib("sinister")
	Global.wave += 1
	main_node.get_node("World").handle_spawn()

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

func _on_camera_button_pressed() -> void:
	camera_mode_enabled = !camera_mode_enabled
	if camera_mode_enabled:
		indicator.visible = false
	else:
		indicator.visible = true
	var current_level : Node3D = main_node.get_node("World")
	var player:CharacterBody3D = current_level.get_node("Player")
	player.camera_selected()

func _on_exit_game_pressed() -> void:
	get_tree().quit()

func _on_close_stats_pressed() -> void:
	in_tower_stats = false
	selected_tower.deselect_tower()


func _on_ice_button_pressed() -> void:
	buy_tower(300, ice)


func _on_flame_button_pressed() -> void:
	buy_tower(300, flame)


func _on_complete_timer_timeout() -> void:
	print("Game is completed!")
	Global.game_complete = true
