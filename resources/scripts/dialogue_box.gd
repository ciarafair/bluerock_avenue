extends CanvasLayer

@onready var DialogueTextBox: RichTextLabel = %DialogueLabel
@onready var NameTextBox: RichTextLabel = %NameLabel
@onready var Arrow: RichTextLabel = %Arrow

enum state {
	READY,
	READING,
	CLEARING,
	FINISHED
}

var StoredText: Dictionary
var DialogueTweenInstance: Tween
var NameTweenInstance: Tween
var CurrentState: state = state.READY

var CurrentKey: int = 1
var KeysArray: Array = []

var ErrorTextEffect: RichTextEffect = null

func set_state(next: state):
	CurrentState = next
	match CurrentState:
		state.READY:
			#print_rich("Changing dialogue box's state to %s" %[NextState])
			#Global.stack_info(get_stack())
			Arrow.set_visible(false)
			return

		state.READING:
			#print_rich("Changing dialogue box's state to %s" %[NextState])
			#Global.stack_info(get_stack())
			Arrow.set_visible(false)
			return

		state.CLEARING:
			#print_rich("Changing dialogue box's state to %s" %[NextState])
			#Global.stack_info(get_stack())
			Arrow.set_visible(false)
			return


		state.FINISHED:
			#print_rich("Changing dialogue box's state to %s" %[NextState])
			#Global.stack_info(get_stack())
			Arrow.set_visible(true)
			return

func reset():
	set_state(state.READY)
	self.set_visible(false)
	NameTextBox.text = ""
	CurrentKey = 1
	DialogueTextBox.text = ""
	DialogueTextBox.visible_ratio = 0

func on_tween_finished():
	set_state(state.FINISHED)

func set_dialogue(text):
	if DialogueTweenInstance != null:
		DialogueTweenInstance.kill()

	DialogueTweenInstance = get_tree().create_tween()
	DialogueTweenInstance.bind_node(DialogueTextBox)
	DialogueTweenInstance.finished.connect(Callable(on_tween_finished))
	DialogueTextBox.set_text("")
	DialogueTextBox.set_text("[font_size=40][outline_size=25][outline_color=black]")
	DialogueTextBox.append_text(str(text))

	DialogueTweenInstance.pause()
	DialogueTweenInstance.tween_property(DialogueTextBox, "visible_ratio", 1.0, len(text) * Global.CharacterReadRate)
	DialogueTweenInstance.play()

func set_dialogue_name(text: String):
	NameTextBox.set_text("")
	NameTextBox.set_text("[font_size=50][outline_size=25][outline_color=black]")
	NameTextBox.append_text(str(text))

func empty_dialogue(text: String):
	if DialogueTweenInstance != null:
		DialogueTweenInstance.kill()

	DialogueTweenInstance = get_tree().create_tween()
	DialogueTweenInstance.bind_node(DialogueTextBox)
	DialogueTweenInstance.pause()
	DialogueTweenInstance.tween_property(DialogueTextBox, "visible_ratio", 0, len(text) * Global.CharacterReadRate)
	DialogueTweenInstance.play()

func start_dialogue(text: Dictionary):
	set_state(state.READING)
	KeysArray = text.keys()
	set_dialogue_name(text.values()[CurrentKey - 1].name)
	set_dialogue(text.values()[CurrentKey - 1].dialogue)
	return

func on_click_dialogue(text: Dictionary):
	#print_rich("Beginning dialogue.")
	#Global.stack_info(get_stack())

	StoredText = text
	if CurrentState == state.READY:
		#print_rich("Clicked while state was %s"%[CurrentState])
		#Global.stack_info(get_stack())
		self.set_visible(true)
		start_dialogue(text)
		return
	return

func next_page():
	set_state(state.CLEARING)
	empty_dialogue(StoredText.values()[CurrentKey - 1].dialogue)
	await DialogueTweenInstance.finished
	CurrentKey += 1
	start_dialogue(StoredText)
	return

func manage_dialogue():
	match CurrentState:
		state.READY:
			return

		state.READING:
			print_rich("Skipping dialogue reading animation")
			Global.stack_info(get_stack())
			DialogueTweenInstance.stop()
			DialogueTextBox.set_visible_ratio(1.0)
			set_state(state.FINISHED)
			return

		state.CLEARING:
			print_rich("Skipping dialogue clearing animation")
			Global.stack_info(get_stack())
			DialogueTweenInstance.stop()
			DialogueTextBox.set_visible_ratio(0.0)
			set_state(state.READING)
			CurrentKey += 1
			start_dialogue(StoredText)
			return

		state.FINISHED:
			if CurrentKey < int(KeysArray.size()):
				print_rich("Turning to next page")
				Global.stack_info(get_stack())
				next_page()
				return

			if CurrentKey >= int(KeysArray.size()):
				print_rich("Closing dialogue box.")
				Global.stack_info(get_stack())
				StoredText = {}
				reset()
				SignalManager.dialogue_close.emit()
				return
	return

func manage_text_effects():
	if ErrorTextEffect == null:
		ErrorTextEffect = err.new()
	if not DialogueTextBox.custom_effects.has(ErrorTextEffect):
		DialogueTextBox.custom_effects.append(ErrorTextEffect)
	return

func manage_signals():
	if not SignalManager.click_dialogue.is_connected(Callable(on_click_dialogue)):
		SignalManager.click_dialogue.connect(Callable(on_click_dialogue))

	if not SignalManager.main_menu_loaded.is_connected(Callable(self.queue_free)):
		SignalManager.main_menu_loaded.connect(Callable(self.queue_free))

	if not SignalManager.manage_dialogue.is_connected(Callable(manage_dialogue)):
		SignalManager.manage_dialogue.connect(Callable(manage_dialogue))

func _ready():
	set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	reset()
	manage_signals()
	return

func _process(_delta):
	manage_text_effects()

	if Global.DialogueBoxInstance == null:
		Global.DialogueBoxInstance = self
		SignalManager.dialogue_box_loaded.emit()

func _on_tree_exiting():
	print_rich("Freeing %s" %[self.name])
	Global.stack_info(get_stack())
