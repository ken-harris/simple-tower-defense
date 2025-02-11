extends CharacterBody3D

var shot_from : Tower
var target : CharacterBody3D
var speed : int = 20
var bullet_damage : int

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		velocity = global_position.direction_to(target.global_position) * speed
		look_at(target.global_position)
		move_and_slide()
	else:
		queue_free()
		


func _on_collision_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		body.take_damage(bullet_damage, shot_from)
		queue_free()
