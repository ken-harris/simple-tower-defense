extends Tower

func _ready() -> void:
	bullet = preload("res://Scenes/Ammo/small_bullet.tscn")

func shoot() -> void:
	handle_shot($WeaponMesh/Aim1.global_position)
	handle_shot($WeaponMesh/Aim2.global_position)
