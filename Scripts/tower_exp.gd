extends StaticBody3D

@onready var exp_bar_3d: Sprite3D = $ExpBar3D

func _ready() -> void:
	exp_bar_3d.set_up(0)

func update_bar(value:int) -> void:
	exp_bar_3d.update(value)

func get_total_exp() -> int:
	return exp_bar_3d.get_exp()
	
func set_max_level() -> void:
	exp_bar_3d.max_level()
	
func set_level(level:int) -> void:
	exp_bar_3d.set_level(level)
