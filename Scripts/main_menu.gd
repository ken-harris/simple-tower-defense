extends Panel

@onready var world : PackedScene = preload("res://Scenes/world.tscn")
@onready var main_3d: Node3D = $"../../../Main3D"
@onready var main:Control = $"../../.."
@onready var settings:VBoxContainer = $Settings
@onready var main_menu:VBoxContainer = $MainMenu
@onready var credits:VBoxContainer = $Credits


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_new_game_pressed() -> void:
	var world_instance = world.instantiate()
	main_3d.add_child(world_instance)
	self.visible = false
	main.in_main_menu = false


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