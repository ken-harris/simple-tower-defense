extends Node3D

@onready var cam : Camera3D = $Camera3D
@onready var music : AudioStreamPlayer2D = $Music

func _ready() -> void:
	music.play_sound_effect_from_lib("music")

func _process(_delta: float) -> void:
	handle_ui()

func handle_ui() -> void:
	$Map/TowerRoundSampleF/HealthBar3D.update(Global.health)
