extends Panel

@onready var world1 : PackedScene = preload("res://Scenes/world1.tscn")
@onready var world2 : PackedScene = preload("res://Scenes/world2.tscn")
@onready var main_3d: Node3D = $"../../../Main3D"
@onready var main:Node3D = $"../../.."
@onready var settings:VBoxContainer = $Settings
@onready var main_menu:VBoxContainer = $MainMenu
@onready var level_select:HFlowContainer = $LevelSelect
@onready var credits:VBoxContainer = $Credits
@onready var sound_effects: AudioStreamPlayer2D = $"../../../SoundEffects"


func _on_new_game_pressed() -> void:
	#sound_effects.play_sound_effect_from_lib("select")
	level_select.visible = true
	main_menu.visible = false


func _on_settings_pressed() -> void:
	settings.visible = true
	main_menu.visible = false


func _on_credits_pressed() -> void:
	main_menu.visible = false
	credits.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_save_settings_pressed() -> void:
	var music_volume = settings.get_node("Music Slider").value
	var sound_volume = settings.get_node("Sound Slider").value
	Global.music_volume = music_volume
	Global.sound_volume = sound_volume
	settings.visible = false
	main_menu.visible = true


func _on_cancel_settings_pressed() -> void:
	settings.get_node("Music Slider").value = Global.music_volume
	settings.get_node("Sound Slider").value = Global.sound_volume
	settings.visible = false
	main_menu.visible = true

func _on_close_credits_pressed() -> void:
	main_menu.visible = true
	credits.visible = false


func _on_new_game_mouse_entered() -> void:
	sound_effects.play_sound_effect_from_lib("hover")


func _on_level_1_pressed() -> void:
	var world_instance = world1.instantiate()
	main_3d.add_child(world_instance)
	main.in_main_menu = false
	self.visible = false

func _on_level_2_pressed() -> void:
	var world_instance = world2.instantiate()
	main_3d.add_child(world_instance)
	main.in_main_menu = false
	self.visible = false

func _on_level_3_pressed() -> void:
	var world_instance = world1.instantiate()
	main_3d.add_child(world_instance)
	main.in_main_menu = false
	self.visible = false
