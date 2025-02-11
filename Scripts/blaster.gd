extends Tower

func shoot() -> void:
	handle_shot($WeaponMesh/Aim1.global_position)
	handle_shot($WeaponMesh/Aim2.global_position)
