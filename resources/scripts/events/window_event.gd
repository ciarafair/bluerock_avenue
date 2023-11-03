extends LocationBlock
class_name WindowEvent

@export var Is_Window_Open: bool

var MoveablePaneInstance: Node3D
var WindowTweenInstance: Tween
var Window_Closing_Time: float = 0
var Window_Open_Amount: float = 34
var MoveablePaneOriginalXPosition: float

func find_movable_pane(_node):
	for child in _node.get_children():
		if child is Node3D && child.name == "MoveablePane":
			#print_debug("Found "+ str(child.name) + "for " + str(self.name) + " in " + str(self.BlockParent.name))
			self.MoveablePaneInstance = child
		elif child is Node3D && child.name != "MoveablePane":
			find_movable_pane(child)
		else:
			pass

func on_tween_finished():
	if Global.Is_Window_Being_Opened == true:
		Global.Is_Window_Being_Opened = false
		Global.Is_Window_Open = true
		#push_warning("Window opened. Game over.")
		SignalManager.game_over.emit()
		get_tree().paused = true
		return

	elif Global.Is_Window_Being_Closed == true:
		Global.Is_Window_Being_Closed = false
		Global.Is_Window_Open = false
		#print_debug("Window was closed in time. Continuing game.")
		SignalManager.reset_monster.emit()
		return

func on_open_window(_node):
	#print_debug(str(self.name) + " from " + str(self.BlockParent.name) + " is being opened")
	if self == _node:
		if WindowTweenInstance:
			WindowTweenInstance.kill()

		WindowTweenInstance = get_tree().create_tween()
		WindowTweenInstance.finished.connect(on_tween_finished)

		if self.MoveablePaneInstance != null:
			Global.Is_Window_Being_Opened = true
			Global.Is_Window_Being_Closed = false
			#print_debug(str(self.name) + " from " + str(self.BlockParent.name) + " is being opened: " + str(Global.Is_Window_Being_Opened))
			#print_debug(str(self.name) + " from " + str(self.BlockParent.name) + " is being closed: " + str(Global.Is_Window_Being_Closed))
			WindowTweenInstance.tween_property(self.MoveablePaneInstance, "position:x", self.MoveablePaneInstance.position.x + Window_Open_Amount, 2.5).from_current()
			return
		else:
			push_error("Moveable pane returned null. Could not animate.")
			pass

func on_close_window(_node):
	#print_debug(str(self.name) + " from " + str(self.BlockParent.name) + " is being closed")
	if self == _node:
		if WindowTweenInstance:
			WindowTweenInstance.kill()

		WindowTweenInstance = get_tree().create_tween()
		WindowTweenInstance.finished.connect(on_tween_finished)

		if self.MoveablePaneInstance != null:
			Global.Is_Window_Being_Closed = true
			Global.Is_Window_Being_Opened = false
			SignalManager.window_close_sound.emit(_node, WindowTweenInstance.get_total_elapsed_time())
			WindowTweenInstance.tween_property(self.MoveablePaneInstance, "position:x", self.MoveablePaneOriginalXPosition, Window_Closing_Time).from_current()
			return

		elif self.MoveablePaneIntance == null:
			push_error("Moveable pane returned null. Could not animate.")
			return
	else:
		pass

func manage_event_signals():
	if Global.Monster_Current_Room == self.BlockParent:
		if SignalManager.open_window.is_connected(on_open_window):
			pass
		else:
			SignalManager.open_window.connect(on_open_window)

		if SignalManager.close_window.is_connected(on_close_window):
			pass
		else:
			SignalManager.close_window.connect(on_close_window)

	if Global.Monster_Current_Room != self.BlockParent:
		if !SignalManager.open_window.is_connected(on_open_window):
			pass
		else:
			SignalManager.open_window.disconnect(on_open_window)

		if !SignalManager.close_window.is_connected(on_close_window):
			pass
		else:
			SignalManager.close_window.disconnect(on_close_window)

func manage_block_signals():
	if SignalManager.activate_block.is_connected(on_activate_block) and SignalManager.deactivate_block.is_connected(on_deactivate_block):
		if Global.Current_Active_Block != self:
			SignalManager.activate_block.disconnect(on_activate_block)
			SignalManager.deactivate_block.disconnect(on_deactivate_block)
	else:
		if Global.Current_Active_Block == self:
			SignalManager.activate_block.connect(on_activate_block)
			SignalManager.deactivate_block.connect(on_deactivate_block)

	if Global.Hovering_Block == self and !SignalManager.activate_block.is_connected(on_activate_block):
		SignalManager.activate_block.connect(on_activate_block)


func start_event():
	#print_debug("Starting event " + self.name)
	Global.Current_Event = "window"

func _ready():
	search_for_parent_block(self)
	search_for_camera_position(self)
	search_for_collider(self)
	find_movable_pane(self)

	if self.BlockCollider != null:
		self.BlockCollider.set_disabled(true)

	if self.BlockCollider == null:
		printerr(str(self.name) + " does not have a collider.")

func _process(_delta):
	#print_debug(str(self.BlockParent))
	set_rotation_ability()
	manage_block_signals()
	manage_event_signals()

	if WindowTweenInstance != null:
		self.Window_Closing_Time = WindowTweenInstance.get_total_elapsed_time() / 2

	if self.MoveablePaneInstance != null && self.MoveablePaneOriginalXPosition == 0:
		self.MoveablePaneOriginalXPosition = self.MoveablePaneInstance.position.x

	if Global.Current_Active_Block == self && Global.Current_Event != "window":
		search_for_props(self, true)
		start_event()

	if Global.Monster_Current_Room != self.BlockParent:
		if MoveablePaneInstance.position.x != MoveablePaneOriginalXPosition:
			MoveablePaneInstance.position.x = MoveablePaneOriginalXPosition
