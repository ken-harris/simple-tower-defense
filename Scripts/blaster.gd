extends StaticBody3D

var bullet : PackedScene = preload("res://Scenes/bullet.tscn")
@onready var polyphonic_audio_player: AudioStreamPlayer2D = $PolyphonicAudioPlayer


var bullet_damage : int = 1
var current_targets : Array[CharacterBody3D] = []
var currently_shooting : CharacterBody3D
var can_shoot : bool = true

func _process(delta: float) -> void:
	if is_instance_valid(currently_shooting):
		look_at(currently_shooting.global_position)
		if can_shoot:
			shoot()
			can_shoot = false
			$ShotCooldown.start()
	else:
		for i in get_node("BulletContainer").get_child_count():
			get_node("BulletContainer").get_child(i).queue_free()

func shoot() -> void:
	var temp_bullet_1 : CharacterBody3D = bullet.instantiate()
	temp_bullet_1.target = currently_shooting
	temp_bullet_1.bullet_damage = bullet_damage
	get_node("BulletContainer").add_child(temp_bullet_1)
	temp_bullet_1.global_position = $WeaponMesh/Aim1.global_position
	polyphonic_audio_player.play_sound_effect_from_lib("shoot")
	
	var temp_bullet_2 : CharacterBody3D = bullet.instantiate()
	temp_bullet_2.target = currently_shooting
	temp_bullet_2.bullet_damage = bullet_damage
	get_node("BulletContainer").add_child(temp_bullet_2)
	temp_bullet_2.global_position = $WeaponMesh/Aim2.global_position
	polyphonic_audio_player.play_sound_effect_from_lib("shoot")

func choose_target(_current_targets : Array[CharacterBody3D]) -> void:
	var temp_array : Array[CharacterBody3D] = _current_targets
	var current_target : CharacterBody3D = null
	for i in temp_array:
		if current_target == null:
			current_target = i
		else:
			if i.get_parent().get_progress() > current_target.get_parent().get_progress():
				current_target = i
	
	currently_shooting = current_target

func _on_mob_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		current_targets.append(body)
		choose_target(current_targets)

func _on_mob_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		current_targets.erase(body)
		choose_target(current_targets)

func _on_shot_cooldown_timeout() -> void:
	can_shoot = true
