extends StaticBody3D

class_name Tower

@onready var polyphonic_audio_player: AudioStreamPlayer2D = $PolyphonicAudioPlayer
@onready var shot_cooldown:Timer = $ShotCooldown
@onready var mob_detector:Area3D = $MobDetector
@export var bullet_damage : int
@onready var stats_panel:Panel = $"../../CanvasLayer/UI/StatsPanel"
@onready var parent : StaticBody3D = get_parent_node_3d()
@onready var range_indicator:MeshInstance3D = $MobDetector/DisplayRange

var bullet : PackedScene
var current_targets : Array[CharacterBody3D] = []
var currently_shooting : CharacterBody3D
var can_shoot : bool = true
var experience_total : int = 0
var level : int = 1
var is_tower:bool = true
var is_selected:bool = false
var cause_slow:bool = false
var cause_burn:bool = false


func update_exp(experience:int) -> void:
	if level == Global.max_level:
		return
	experience_total += experience
	# Since I moved the xp bar up a level I have to update the parent for the view
	# which fixes the issue with the look_at function moving the bar
	parent.update_bar(experience_total)
	#print("Wait time: " + str(shot_cooldown.wait_time))
	
	if parent.get_total_exp() >= 100:
		#print("LEVELED UP!")
		polyphonic_audio_player.play_sound_effect_from_lib("level")
		# Level up:
		# Increase level
		level += 1
		# Increase shot speed
		shot_cooldown.wait_time = shot_cooldown.wait_time * Global.fire_speed_upgrade
		# Increase damage
		bullet_damage = bullet_damage * Global.damage_upgrade
		# Increase range
		var col_shape:CollisionShape3D = $MobDetector/CollisionShape3D
		col_shape.shape.radius = col_shape.shape.radius * Global.range_upgrade
		# Reset Experience
		experience_total -= 100
		parent.update_bar(experience_total)
		parent.set_level(level)
		# If max level then remove experience?
		if level == Global.max_level:
			parent.set_max_level()
		# Show level somewhere on tower?
	

func handle_shot(pos) -> void:
	polyphonic_audio_player.play_sound_effect_from_lib("shoot")
	var temp_bullet : CharacterBody3D = bullet.instantiate()
	temp_bullet.shot_from = self
	temp_bullet.target = currently_shooting
	temp_bullet.bullet_damage = bullet_damage
	temp_bullet.cause_slow = cause_slow
	temp_bullet.cause_burn = cause_burn
	get_node("BulletContainer").add_child(temp_bullet)
	temp_bullet.global_position = pos

func shoot() -> void:
	handle_shot($WeaponMesh/Aim.global_position)

func _process(_delta: float) -> void:
	# Moved to _process so that the text gets updated in real time
	if is_selected:
		var stat_container:VBoxContainer = stats_panel.get_node("VBoxContainer")
		var range:float = mob_detector.get_node("CollisionShape3D").shape.radius
		for child in stat_container.get_children():
			match child.name:
				"TowerType":
					child.text = self.name
				"Level":
					child.text = "Level: " + "Max" if level == Global.max_level else str(level)
				"Damage":
					child.text = "Damage: " + str(bullet_damage)
				"Speed":
					child.text = "Speed: " + str("%.2f" % shot_cooldown.wait_time) + "/s"
				"Range":
					child.text = "Range: " + str("%.2f" % range) + "m"
		
	if is_instance_valid(currently_shooting):
		look_at(currently_shooting.global_position)
		if can_shoot:
			shoot()
			can_shoot = false
			$ShotCooldown.start()
	else:
		for i in get_node("BulletContainer").get_child_count():
			get_node("BulletContainer").get_child(i).queue_free()

func select_tower() -> void:
	is_selected = true
	range_indicator.visible = true
	
func deselect_tower() -> void:
	is_selected = false
	range_indicator.visible = false

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
