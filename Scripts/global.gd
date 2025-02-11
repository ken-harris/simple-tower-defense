extends Node

var health : int = 100
var money : int = 3000
var wave : int = 0
var enemies_alive : int = 0
var fire_speed_upgrade:float = 0.8
var damage_upgrade:float = 1.25
var range_upgrade:float = 1.10
var max_level:int = 5

func reset() -> void:
	health = 100
	money = 3000
	wave  = 0
	enemies_alive = 0
