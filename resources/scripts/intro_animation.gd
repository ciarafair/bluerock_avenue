extends CanvasLayer

@export var DialoguePath: String

func manage_dialogue(path: String):
	var json = load(path)
	var stringified_json = Global.stringify_json(json)
	#print_rich("Activating %s with the dialogue %s." %[self.name, stringified_json])
	#Global.stack_info(get_stack())
	SignalManager.click_dialogue.emit(self, stringified_json)

func _process(_delta):
	if Global.IntroAnimationInstance == null:
		Global.IntroAnimationInstance = self
		SignalManager.intro_animation_loaded.emit()
		#print_rich("Loaded intro animation")
		#Global.stack_info(get_stack())

	await SignalManager.dialogue_close
	SignalManager.intro_animation_completed.emit()
	Global.Settings_Data_Instance.Skip_Introduction = true
	SignalManager.save_settings_data.emit()
	self.queue_free()

func _ready():
	if DialoguePath != null:
		manage_dialogue(DialoguePath)
		#print_rich("Loaded dialogue for animation")
		#Global.stack_info(get_stack())
	else:
		printerr("%s is missing a dialogue path." %[self.name])
		Global.stack_info(get_stack())
