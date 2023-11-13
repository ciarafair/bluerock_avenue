extends CanvasLayer

@onready var TaskLabel = %TaskLabel

var TweenInstance: Tween
var ExpireTimer: Timer
var CurrentState: state = state.READY
var CurrentTask: Global.task

enum state {
	READY,
	READING,
	FINISHED
}

func set_state(next):
	CurrentState = next
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
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(self)
	TweenInstance.finished.connect(Callable(on_tween_finished))

	TweenInstance.pause()
	TweenInstance.tween_property(TaskLabel, "visible_ratio", 0.0, len(TaskLabel.text) * Global.CharacterReadRate)
	TweenInstance.play()

	await TweenInstance.finished

	TaskLabel.text = ""
	set_state(state.READY)

func on_tween_finished():
	if ExpireTimer:
		ExpireTimer.queue_free()

	ExpireTimer = Timer.new()
	ExpireTimer.autostart = false
	self.add_child(ExpireTimer)

	set_state(state.FINISHED)

func find_task_text():
	if Global.Game_Data_Instance.Current_Task != self.CurrentTask:
		CurrentTask = Global.Game_Data_Instance.Current_Task
		#print_debug("Recieved signal")
		var text: String
		if Global.Game_Data_Instance.Current_Task == Global.task.TURN_OFF_TV:
			text = "Turn off television"
			#print_debug("Setting text to %s" %[text])
			set_task_label_text(text)
			return
		elif Global.Game_Data_Instance.Current_Task == Global.task.EXPLORE:
			text = "Investigate sound coming from the office"
			#print_debug("Setting text to %s" %[text])
			reset()
			await TweenInstance.finished
			set_task_label_text(text)
			return
		text = ""
		return text
	else:
		pass

func set_task_label_text(text):
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(self)
	TweenInstance.finished.connect(Callable(on_tween_finished))
	TaskLabel.text = "- " + str(text)

	TweenInstance.pause()
	TweenInstance.tween_property(TaskLabel, "visible_ratio", 1.0, len(text) * Global.CharacterReadRate)
	TweenInstance.play()
	return

func manage_visibility():
	if Global.Is_Pause_Menu_Open == true:
		self.set_visible(false)
		return
	elif Global.Is_Pause_Menu_Open == false:
		self.set_visible(true)
		return

func manage_signals():
	SignalManager.show_pause_menu.connect(Callable(self.set_visible).bind(false))
	SignalManager.hide_pause_menu.connect(Callable(self.set_visible).bind(true))
	SignalManager.set_task.connect(Callable(find_task_text))
	SignalManager.main_menu_loaded.connect(Callable(self.queue_free))
	return

func _ready():
	manage_signals()

func _process(_delta):
	if Global.TaskListInstance == null:
		SignalManager.task_list_loaded.emit()
		Global.TaskListInstance = self

	manage_visibility()
	find_task_text()

	if Global.Game_Data_Instance.Current_Task == Global.task.TURN_OFF_TV:
		Global.Game_Data_Instance.Is_Monster_Active = false
	if Global.Game_Data_Instance.Current_Task == Global.task.EXPLORE:
		Global.Game_Data_Instance.Is_Monster_Active = false
	if Global.Game_Data_Instance.Current_Task == Global.task.SURVIVE:
		Global.Game_Data_Instance.Is_Monster_Active = true