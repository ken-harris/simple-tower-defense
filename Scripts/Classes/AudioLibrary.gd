extends Resource
class_name AudioLibrary

@export var sound_effects: Array[SoundEffect]

func get_audio_stream(_tag: String) -> AudioStream:
	if _tag:
		return sound_effects.filter(func (sound : SoundEffect): return sound.tag == _tag).front().stream
	else:
		printerr("Tag is invalid.")
		return null
