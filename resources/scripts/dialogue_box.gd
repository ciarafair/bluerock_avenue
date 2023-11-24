extends CanvasLayer

@onready var DialogueTextBox: RichTextLabel = %DialogueLabel
@onready var NameTextBox: Label = %NameLabel
@onready var CloseButton: Button = %Close
@onready var SkipButton: Button = %Skip
@onready var NextButton: Button = %Next

enum state {
	READY,
	READING,
	FINISHED
}

var StoredText: Dictionary
var TweenInstance: Tween
var CurrentState: state = state.READY

var CurrentKey: int = 1
var KeysArray: Array = []

func set_state(next):
	CurrentState = next
	match CurrentState:
		state.READY:
			#print_rich("Changing dialogue box's state to %s" %[NextState])
			#Global.stack_info(get_stack())
			pass

		state.READING:
			#print_rich("Changing dialogue box's state to %s" %[NextState])
			#Global.stack_info(get_stack())
			pass

		state.FINISHED:
			#print_rich("Changing dialogue box's state to %s" %[NextState])
			#Global.stack_info(get_stack())
			pass

func reset():
	set_state(state.READY)
	self.set_visible(false)
	NameTextBox.text = ""
	DialogueTextBox.text = ""
	DialogueTextBox.visible_ratio = 0

func on_tween_finished():
	set_state(state.FINISHED)

func set_dialogue(text):
	if TweenInstance != null:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.bind_node(DialogueTextBox)
	TweenInstance.finished.connect(Callable(on_tween_finished))
	DialogueTextBox.set_text("")
	DialogueTextBox.set_text("[font_size=40][outline_size=25] [outline_color=black]")
	DialogueTextBox.append_text(" " + str(text))

	TweenInstance.pause()
	TweenInstance.tween_property(DialogueTextBox, "visible_ratio", 1.0, len(text) * Global.CharacterReadRate)
	TweenInstance.play()

func set_dialogue_name(text: String):
	NameTextBox.text = str(text)

func empty_dialogue(text: String):
	if TweenInstance != null:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.bind_node(DialogueTextBox)
	TweenInstance.pause()
	TweenInstance.tween_property(DialogueTextBox, "visible_ratio", 0, len(text) * Global.CharacterReadRate)
	TweenInstance.play()

func start_dialogue(text: Dictionary):
	set_state(state.READING)

	#print_rich("The block %s has dialogue: %s" %[node, parsed_data])
	#Global.stack_info(get_stack())
	KeysArray = text.keys()
	#print_rich("Total keys in dictionary: %s" %[KeysArray.size()])
	#Global.stack_info(get_stack())
	#print_rich("Current key is: %s" %[text.keys()[CurrentKey - 1]])
	#Global.stack_info(get_stack())

	set_dialogue_name(text.values()[CurrentKey - 1].name)
	set_dialogue(text.values()[CurrentKey - 1].dialogue)
	return

func on_click_dialogue(_node: Node, text: Dictionary):
	StoredText = text
	if CurrentState == state.READY:
		#print_rich("Clicked while state was %s"%[CurrentState])
		#Global.stack_info(get_stack())
		self.set_visible(true)
		start_dialogue(text)
		return
	return

func next_page():
	empty_dialogue(StoredText.values()[CurrentKey - 1].dialogue)
	await TweenInstance.finished
	CurrentKey += 1
	start_dialogue(StoredText)
	return

func _on_skip_button_button_up():
	TweenInstance.stop()
	DialogueTextBox.set_visible_ratio(1.0)
	set_state(state.FINISHED)
	return

func _on_close_button_up():
	self.queue_free()
	StoredText = {}
	return

func _on_next_button_up():
	next_page()

func manage_buttons():
	if CurrentState == state.READY:
		SkipButton.set_visible(false)
		CloseButton.set_visible(false)
		NextButton.set_visible(false)
		return

	if CurrentState == state.READING:
		SkipButton.set_visible(true)
		NextButton.set_visible(false)
		CloseButton.set_visible(false)
		return

	if CurrentState == state.FINISHED:
		SkipButton.set_visible(false)
		if CurrentKey < int(KeysArray.size()):
			#print_rich("%s > %s" %[CurrentKey, KeysArray.size()])
			#Global.stack_info(get_stack())
			NextButton.set_visible(true)
			CloseButton.set_visible(false)
			return

		if CurrentKey >= int(KeysArray.size()):
			#print_rich("%s <= %s" %[CurrentKey, KeysArray.size()])
			#Global.stack_info(get_stack())
			CloseButton.set_visible(true)
			NextButton.set_visible(false)
			return
	return

func manage_signals():
	SignalManager.click_dialogue.connect(Callable(on_click_dialogue))
	SignalManager.main_menu_loaded.connect(Callable(self.queue_free))

func _ready():
	set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	reset()
	manage_signals()
	return

func _process(_delta):
	manage_buttons()

	if Global.DialogueBoxInstance == null:
		Global.DialogueBoxInstance = self
		SignalManager.dialogue_box_loaded.emit()

