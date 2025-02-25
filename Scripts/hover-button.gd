extends Button

@onready var sound_effects: AudioStreamPlayer2D = $SoundEffects

func _on_mouse_entered() -> void:
	sound_effects.play_sound_effect_from_lib("hover")


func _on_button_down() -> void:
	sound_effects.play_sound_effect_from_lib("select")
