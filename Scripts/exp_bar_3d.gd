extends Sprite3D

@onready var bar : ProgressBar = $SubViewport/ExperiencePoints

func _ready() -> void:
	texture = $SubViewport.get_texture()
	
func set_up(value : int) -> void:
	bar.value = value
	
func update(value : int) -> void:
	bar.value = value

func get_exp() -> int:
	return bar.value

func set_level(level:int) -> void:
	var LevelLabel:Label = bar.get_child(0)
	LevelLabel.text = str(level)

func max_level() -> void:
	bar.value = 100
	var style_box:StyleBox = bar.get("theme_override_styles/fill")
	style_box.bg_color = Color(1,1,0)
