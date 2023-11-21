extends LocationBlock
class_name WindowBlock

@export var Is_Window_Open: bool

var MoveablePaneInstance: Node3D
var WindowTweenInstance: Tween
var Window_Closing_Time: float = 0
var Window_Open_Amount: float = 34
var MoveablePaneOriginalXPosition: float

func find_movable_pane(_node):
	for child in _node.get_children():
		if child is Node3D && child.name == "MoveablePane":
			#print_rich("Found "+ str(child.name) + "for " + str(self.name) + " in " + str(self.BlockParent.name))
			#Global.stack_info(get_stack())
			self.MoveablePaneInstance = child
		elif child is Node3D && child.name != "MoveablePane":
			find_movable_pane(child)
		else:
			pass

func on_window_tween_finished():
	if Global.Is_Window_Being_Opened == true:
		Global.Is_Window_Being_Opened = false
		Global.Is_Window_Open = true
		SignalManager.game_over.emit()
		get_tree().paused = true
		return

	Global.Is_Window_Being_Closed = false
	Global.Is_Window_Open = false
	print_rich("Window was closed in time. Continuing game.")
	Global.stack_info(get_stack())
	SignalManager.reset_monster.emit()
	return

func on_open_window(node: WindowBlock):
	if node != null:
		print_rich("The %s from %s is being opened" %[str(self.name), str(self.BlockParent.name)])
		Global.stack_info(get_stack())
		if WindowTweenInstance:
			WindowTweenInstance.kill()

		WindowTweenInstance = get_tree().create_tween()
		WindowTweenInstance.finished.connect(on_window_tween_finished)

		if node.MoveablePaneInstance != null:
			Global.Is_Window_Being_Opened = true
			Global.Is_Window_Being_Closed = false
			#print_rich(str(self.name) + " from " + str(self.BlockParent.name) + " is being opened: " + str(Global.Is_Window_Being_Opened))
			#Global.stack_info(get_stack())
			#print_rich(str(self.name) + " from " + str(self.BlockParent.name) + " is being closed: " + str(Global.Is_Window_Being_Closed))
			#Global.stack_info(get_stack())
			WindowTweenInstance.tween_property(node.MoveablePaneInstance, "position:x", node.MoveablePaneOriginalXPosition + Window_Open_Amount, 2.5)
		return
	else:
		printerr("Moveable pane returned null. Could not animate.")
		Global.stack_info(get_stack())
		pass

func on_close_window(node):
	print_rich(str(self.name) + " from " + str(self.BlockParent.name) + " is being closed")
	Global.stack_info(get_stack())
	if WindowTweenInstance:
		WindowTweenInstance.kill()

	WindowTweenInstance = get_tree().create_tween()
	WindowTweenInstance.finished.connect(on_window_tween_finished)

	if node.MoveablePaneInstance != null:
		Global.Is_Window_Being_Closed = true
		Global.Is_Window_Being_Opened = false
		SignalManager.window_close_sound.emit(node, WindowTweenInstance.get_total_elapsed_time())
		WindowTweenInstance.tween_property(node.MoveablePaneInstance, "position:x", node.MoveablePaneOriginalXPosition, Window_Closing_Time).from_current()
		return

	elif node.MoveablePaneIntance == null:
		printerr("Moveable pane returned null. Could not animate.")
		Global.stack_info(get_stack())
		return
	else:
		pass

func manage_event_signals():
	if Global.Game_Data_Instance.Monster_Current_Room == str(self.BlockParent.get_path()):
		if SignalManager.open_window.is_connected(on_open_window):
			pass
		else:
			SignalManager.open_window.connect(on_open_window)

		if SignalManager.close_window.is_connected(on_close_window):
			pass
		else:
			SignalManager.close_window.connect(on_close_window)
		return

	if SignalManager.open_window.is_connected(on_open_window):
		SignalManager.open_window.disconnect(on_open_window)
	if SignalManager.close_window.is_connected(on_close_window):
		SignalManager.close_window.disconnect(on_close_window)
	return

func start_event():
	#print_rich("Starting event " + self.name)
	Global.Game_Data_Instance.Current_Event = "window"

func _ready():
	block_ready()
	find_movable_pane(self)

	if self.MoveablePaneInstance != null:
		self.MoveablePaneOriginalXPosition = self.MoveablePaneInstance.position.x

func _process(_delta):
	#print_rich(str(self.BlockParent))
	set_rotation_ability()
	manage_event_signals()

	if WindowTweenInstance != null:
		self.Window_Closing_Time = WindowTweenInstance.get_total_elapsed_time() / 2

	if Global.Game_Data_Instance.Current_Block == self && Global.Game_Data_Instance.Current_Event != "window":
		search_for_props(self, true)
		start_event()

	if Global.Game_Data_Instance.Monster_Current_Room != str(self.BlockParent.get_path()):
		if self.MoveablePaneInstance.position.x != self.MoveablePaneOriginalXPosition:
			self.MoveablePaneInstance.position.x = self.MoveablePaneOriginalXPosition
