extends World

@onready var spawn_1 : Timer = $SpawnTimer
@onready var path_1 : Path3D = $Path

var waves = [[5],[8],[10],[15],[17]]
var current_enemies_to_spawn_1 : int = 0

func _ready() -> void:
    super._ready()
    Global.total_waves = len(waves)
    Global.level = 1

func handle_spawn() -> void:
    Global.wave_ongoing = true
    spawn_1.start()
    current_enemies_to_spawn_1 = waves[Global.wave-1][0]
    Global.wave_enemies_remain = current_enemies_to_spawn_1

func _on_spawn_timer_timeout() -> void:
    if current_enemies_to_spawn_1 > 0:
        var temp_enemy = enemy.instantiate()
        path_1.add_child(temp_enemy)
        current_enemies_to_spawn_1 -= 1
        Global.enemies_alive += 1
        Global.wave_enemies_remain -= 1
    if current_enemies_to_spawn_1 == 0:
        spawn_1.stop()
        Global.wave_ongoing = false