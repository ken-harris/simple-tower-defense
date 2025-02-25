extends CharacterBody3D

@export var max_speed:float = 4.0
@export var acceleration:float = 20.0

var look_sensitivity:float = 0.005
var camera_look_input:Vector2
@onready var camera:Camera3D = get_node("Camera3D")
var gravity_modifier:float = 1.5
@onready var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier

var is_going_up:bool = false
var is_going_down:bool = false

func _ready():
	# Locks the mouse inside of the window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	var move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	
	var target_velocity = move_dir * max_speed
	var current_smothing = acceleration
	
	if Input.is_action_pressed("jump"):
		velocity.y = lerp(5.0, target_velocity.y, current_smothing * delta)
		is_going_up = true
	
	if Input.is_action_pressed("lower"):
		velocity.y = lerp(-5.0, target_velocity.y, current_smothing * delta)
		is_going_down = true
	
	if is_going_up:
		velocity.y -= gravity * delta
		if velocity.y <= 0:
			velocity.y = 0
			is_going_up = false
	if is_going_down:
		velocity.y += gravity * delta
		if velocity.y >= 0:
			velocity.y = 0
			is_going_down = false
	
	velocity.x = lerp(velocity.x, target_velocity.x, current_smothing * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, current_smothing * delta)
	
	move_and_slide()
	
	# Camera Look
	rotate_y(-camera_look_input.x * look_sensitivity)
	
	camera.rotate_x(-camera_look_input.y * look_sensitivity)
	#camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	camera_look_input = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_look_input = event.relative
