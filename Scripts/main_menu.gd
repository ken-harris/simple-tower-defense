extends Panel

@onready var world : PackedScene = preload("res://Scenes/world.tscn")
@onready var main_3d: Node3D = $"../../Main3D"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_pressed() -> void:
	var world_instance = world.instantiate()
	main_3d.add_child(world_instance)
	self.visible = false


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	pass # Replace with function body.
