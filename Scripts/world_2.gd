extends World

@onready var enemy : PackedScene = preload("res://Mobs/ufo.tscn")
@onready var spawn_1 : Timer = $SpawnTimer
@onready var spawn_2 : Timer = $SpawnTimer2
@onready var path_1 : Path3D = $Path
@onready var path_2 : Path3D = $Path2

var waves = [[5,0], [5, 0], [0, 5], [5, 5]]
var current_enemies_to_spawn_1 : int = 0
var current_enemies_to_spawn_2 : int = 0

func _ready() -> void:
	Global.total_waves = len(waves)
	Global.level = 2

func handle_spawn():
	Global.wave_ongoing = true
	spawn_1.start()
	spawn_2.start()
	current_enemies_to_spawn_1 = waves[Global.wave-1][0]
	current_enemies_to_spawn_2 = waves[Global.wave-1][1]

func _on_spawn_timer_timeout() -> void:
	if current_enemies_to_spawn_1 > 0:
		var temp_enemy = enemy.instantiate()
		path_1.add_child(temp_enemy)
		current_enemies_to_spawn_1 -= 1
		Global.enemies_alive += 1
	if current_enemies_to_spawn_1 == 0:
		spawn_1.stop()
		if current_enemies_to_spawn_2 == 0:
			Global.wave_ongoing = false

func _on_spawn_timer_2_timeout() -> void:
	if current_enemies_to_spawn_2 > 0:
		var temp_enemy = enemy.instantiate()
		path_2.add_child(temp_enemy)
		current_enemies_to_spawn_2 -= 1
		Global.enemies_alive += 1
	if current_enemies_to_spawn_2 == 0:
		spawn_2.stop()
		if current_enemies_to_spawn_1 == 0:
			Global.wave_ongoing = false
