extends Node2D

@onready var logo = $AnimatedSprite2D
@onready var sound = $AudioStreamPlayer

func _ready() -> void:
	logo.play("default")
	sound.play()

func _process(delta: float) -> void:
	pass
