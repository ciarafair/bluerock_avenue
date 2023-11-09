extends CanvasLayer

@onready var DialogueTextBox: Label = %DialogueLabel
@onready var NameTextBox: Label = %NameLabel
@onready var CloseButton: Button = %Close
@onready var SkipButton: Button = %Skip

const CharacterReadRate: float = 0.025
const ExpireTimerWaitTime: float = 0.25

enum state {
	READY,
	READING,
	FINISHED
}

var TweenInstance: Tween
var ExpireTimer: Timer
var CurrentState: state = state.READY

func set_state(NextState):
	CurrentState = NextState
	match CurrentState:
		state.READY:
			#print_debug("Changing dialogue box's state to %s" %[NextState])
			pass

		state.READING:
			#print_debug("Changing dialogue box's state to %s" %[NextState])
			pass

		state.FINISHED:
			#print_debug("Changing dialogue box's state to %s" %[NextState])
			pass

func reset():
	set_state(state.READY)
	self.set_visible(false)
	NameTextBox.text = ""
	DialogueTextBox.text = ""
	DialogueTextBox.visible_ratio = 0

func on_tween_finished(text):
	if ExpireTimer:
		ExpireTimer.queue_free()

	ExpireTimer = Timer.new()
	ExpireTimer.autostart = false
	self.add_child(ExpireTimer)

	set_state(state.FINISHED)

	ExpireTimer.start((len(text) * CharacterReadRate) / ExpireTimerWaitTime)
	await ExpireTimer.timeout
	reset()

func set_dialogue(text):
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(DialogueTextBox)
	TweenInstance.finished.connect(Callable(on_tween_finished).bind(text))
	DialogueTextBox.text = str(text)

	TweenInstance.pause()
	TweenInstance.tween_property(DialogueTextBox, "visible_ratio", 1.0, len(text) * CharacterReadRate)
	TweenInstance.play()

func set_dialogue_name(text):
	NameTextBox.text = str(text)

func on_click_dialogue(_node: Block, text):
	if CurrentState == state.READY:
		print_debug("Clicked while state was %s"%[CurrentState])
		self.set_visible(true)
		set_state(state.READING)

		#print_debug("The block %s has dialogue: %s" %[node, parsed_data])
		set_dialogue_name(text.one.name)
		set_dialogue(text.one.dialogue)
		return

	if CurrentState == state.READING:
		print_debug("Clicked while state was %s"%[CurrentState])
		TweenInstance.stop()
		DialogueTextBox.set_visible_ratio(1.0)
		set_state(state.FINISHED)
		return

	if CurrentState == state.FINISHED:
		print_debug("Clicked while state was %s"%[CurrentState])
		self.reset()
		return

func manage_signals():
	SignalManager.click_dialogue.connect(Callable(on_click_dialogue))

func _ready():
	reset()
	manage_signals()

func _process(_delta):
	if CurrentState == state.READY:
		SkipButton.set_visible(false)
		CloseButton.set_visible(false)
		return
	if CurrentState == state.READING:
		SkipButton.set_visible(true)
		CloseButton.set_visible(false)
		return
	if CurrentState == state.FINISHED:
		SkipButton.set_visible(false)
		CloseButton.set_visible(true)
		return
	pass

func _on_skip_button_button_up():
	TweenInstance.stop()
	DialogueTextBox.set_visible_ratio(1.0)
	set_state(state.FINISHED)
	pass # Replace with function body.

func _on_close_button_up():
	self.reset()
	pass # Replace with function body.
