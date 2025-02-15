extends CharacterBody3D


@export var speed : float = 2.0
@export var health : int = 15
@export var experience : int = 10

@onready var Path : PathFollow3D = get_parent()
@onready var polyphonic_audio_player: AudioStreamPlayer2D = $"../PolyphonicAudioPlayer"

var hit_by_towers : Array[Tower] = []
var is_alive : bool = true
var is_boss : bool = false

func _ready():
	$HealthBar3D.set_up(health)

func _physics_process(delta: float) -> void:
	Path.set_progress(Path.get_progress() + speed * delta)
	
	if Path.get_progress_ratio() >= 0.99:
		Global.health -= 20
		death() # Delete the parent path with all children

func take_damage(damage : int, from: Tower) -> void:
	print("Hit by " + str(from) + " for " + str(damage) + " total left: " + str(health))
	if from not in hit_by_towers:
		hit_by_towers.append(from)
	health -= damage
	$HealthBar3D.update(health)
	if health <= 0 and is_alive:
		Global.money += 200 if is_boss else 50
		for tower in hit_by_towers:
			if tower == from:
				from.update_exp(experience)
			else:
				tower.update_exp(roundi(experience / 2))
		death()
		
func death() -> void:
	is_alive = false
	if randi_range(0, 3) == 2: polyphonic_audio_player.play_sound_effect_from_lib("death")
	
	Global.enemies_alive -= 1
	#Path.queue_free()
	self.queue_free()

func create_boss() -> void:
	scale += Vector3.ONE * 0.5
	speed = 1.2
	health = 100
	experience += 25
	is_boss = true
