extends CanvasLayer

@onready var DialogueTextBox = %DialogueRichText
@onready var NameTextBox = %NameRichText

var PlayfairRegular = preload(Path.PlayfairRegularPath)
var PlayfairBold = preload(Path.PlayfairBoldPath)
var PlayfairItalic  = preload(Path.PlayfairItalicath)
var PlayfairBoldItalic  = preload(Path.PlayfairBoldItalicPath)

func set_theme(node: RichTextLabel, font_name: String, font_size: int):
	if font_name == "PlayfairDisplay":
		node.add_theme_font_override("normal_font", PlayfairRegular)
		node.add_theme_font_override("bold_font", PlayfairBold)
		node.add_theme_font_override("italics_font", PlayfairItalic)
		node.add_theme_font_override("bold_italics_font", PlayfairBoldItalic)
	node.add_theme_font_size_override("normal_font_size", font_size)
	node.add_theme_font_size_override("bold_font_size", font_size)
	node.add_theme_font_size_override("bold_italics_font_size", font_size)
	node.add_theme_font_size_override("mono_font_size", font_size)
	node.add_theme_font_size_override("italics_font_size", font_size)
	node.add_theme_constant_override("outline_size", 25)
	node.add_theme_color_override("font_outline_color", "black")

func set_dialogue_name(parsed_data):
	NameTextBox.clear()
	set_theme(NameTextBox, "PlayfairDisplay", 50)
	NameTextBox.add_text(str(parsed_data.one.name))

func set_dialogue(parsed_data):
	DialogueTextBox.clear()
	set_theme(DialogueTextBox, "PlayfairDisplay", 35)
	DialogueTextBox.add_text(str(parsed_data.one.dialogue))

func on_begin_dialogue(node: Block, json_file: JSON):
	self.set_visible(true)

	var path = json_file.resource_path
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning(str(FileAccess.get_open_error()))
		return

	var raw_data = file.get_as_text()
	file.close()

	var parsed_data = JSON.parse_string(raw_data)
	if parsed_data == null:
		push_error("Cannot parse %s as a json-string: %s" % [path, raw_data])
		return

	print_debug("The block %s has dialogue: %s" %[node, parsed_data])
	set_dialogue_name(parsed_data)
	set_dialogue(parsed_data)

func manage_signals():
	SignalManager.begin_dialogue.connect(on_begin_dialogue)

func _ready():
	self.set_visible(false)
	manage_signals()
