extends CharacterBody3D


@export var speed : float = 2.0
@export var health : int = 10
@export var experience : int = 50
@export var gold_on_kill : int = 50

@onready var Path : PathFollow3D = get_parent()
@onready var polyphonic_audio_player: AudioStreamPlayer2D = $"../PolyphonicAudioPlayer"

var hit_by_towers : Array[Tower] = []
var is_alive : bool = true
var is_boss : bool = false
var is_slowed: bool = false
var is_burned: bool = false
var max_burn_ticks:int = 5
var total_burn_ticks:int = 0
var max_slow_ticks:int = 5
var total_slow_ticks:int = 0

func _ready():
	$HealthBar3D.set_up(health)

func _physics_process(delta: float) -> void:
	Path.set_progress(Path.get_progress() + speed * delta)
	
	if Path.get_progress_ratio() >= 0.99:
		Global.health -= 20
		death() # Delete the parent path with all children

func take_damage(damage : int, from: Tower, cause_slow:bool, cause_burn:bool) -> void:
	#print("Hit by " + str(from) + " for " + str(damage) + " total left: " + str(health))
	if cause_slow and not is_slowed:
		is_slowed = true
		speed *= Global.slow_speed
		$SlowTimer.start()
	if cause_slow:
		total_slow_ticks = 0
	if cause_burn and not is_burned:
		is_burned = true
		$BurnTimer.start()
	if cause_burn:
		# Reset burn ticks on hit
		total_burn_ticks = 0
	if from not in hit_by_towers:
		hit_by_towers.append(from)
	health -= damage
	$HealthBar3D.update(health)
	if health <= 0 and is_alive:
		handle_dying(from)

func handle_dying(from):
	Global.money += gold_on_kill * 4 if is_boss else gold_on_kill
	for tower in hit_by_towers:
		if from and from == tower:
			from.update_exp(experience)
		else:
			tower.update_exp(roundi(experience / 2))
	death()

func death() -> void:
	is_alive = false
	if randi_range(0, 3) == 2: polyphonic_audio_player.play_sound_effect_from_lib("death")
	
	Global.enemies_alive -= 1
	self.queue_free()

func create_boss() -> void:
	scale += Vector3.ONE * 0.5
	speed = 1.2
	health = 100
	experience += 25
	is_boss = true


func _on_burn_timer_timeout() -> void:
	total_burn_ticks += 1
	# Deal damage
	health -= Global.burn_damage
	$HealthBar3D.update(health)
	polyphonic_audio_player.play_sound_effect_from_lib("burn")
	if health <= 0 and is_alive:
		handle_dying(null)
	if total_burn_ticks >= max_burn_ticks:
		$BurnTimer.stop()
		is_burned = false

func _on_slow_timer_timeout() -> void:
	total_slow_ticks += 1
	if total_slow_ticks >= max_slow_ticks:
		$SlowTimer.stop()
		is_slowed = false
		# Speed is multiplied by slow_speed when slowed
		# must be divided if removed.
		speed /= Global.slow_speed
