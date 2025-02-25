extends Node3D

@onready var music : AudioStreamPlayer2D = $Music

func _ready() -> void:
	# 30 is basically the lowest before it becomes "muted"
	if Global.music_volume == 0:
		music.volume_db = -100
	else:
		music.volume_db = (Global.music_volume * 3) -35
	music.play_sound_effect_from_lib("music")

func _process(_delta: float) -> void:
	handle_ui()

func handle_ui() -> void:
	$Map/TowerRoundSampleF/HealthBar3D.update(Global.health)
