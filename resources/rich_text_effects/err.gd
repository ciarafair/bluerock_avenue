@tool
extends RichTextEffect
class_name err

# Syntax: [err][/err]
var bbcode = "err"

func _process_custom_fx(char_fx: CharFXTransform):
	var TIME = char_fx.elapsed_time + char_fx.get_glyph_index() * 10.02  + char_fx.range.x * 2
	TIME *= 2.25

	if sin(TIME) > 0.25:
		var rand_index: int = randi() % 323
		char_fx.glyph_index = rand_index

	return true
