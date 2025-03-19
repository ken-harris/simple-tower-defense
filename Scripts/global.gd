extends Node

# Game info
var health : int = 100
var money : int = 3000
var level:int = 0
var wave : int = 0
var enemies_alive : int = 0
var wave_enemies_remain : int = 0
var wave_ongoing:bool = false
var total_waves:int = 0
var game_complete:bool = false

# Tower Upgrades
var fire_speed_upgrade:float = 0.8
var damage_upgrade:float = 1.25
var range_upgrade:float = 1.10
var max_level:int = 5
var slow_speed:float = 0.5
var burn_damage:int = 2

# Settings
var music_volume:int = 10
var sound_volume:int = 10


func reset() -> void:
	health = 100
	money = 3000
	level = 0
	wave  = 0
	enemies_alive = 0
	game_complete = false
	wave_ongoing = false
	total_waves = 0
	game_complete = false
