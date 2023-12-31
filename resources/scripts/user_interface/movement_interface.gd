extends CanvasLayer

@onready var BottomPanel = $Bottom
@onready var LeftPanel = $Left
@onready var RightPanel = $Right

func manage_signals():
	SignalManager.main_menu_loaded.connect(Callable(self.queue_free))

func _ready():
	manage_signals()

func _process(_delta):
	if Global.MovementInterfaceInstance == null:
		SignalManager.movement_interface_loaded.emit()
		Global.MovementInterfaceInstance = self

func _on_left_mouse_entered():
	if Global.Is_Able_To_Turn == true:
		Global.set_mouse_state(Global.mouse.ROTATION)
		Global.Current_Movement_Panel = LeftPanel
		#print_rich("Mouse has entered left section.")
		#Global.stack_info(get_stack())

func _on_left_mouse_exited():
	Global.Current_Movement_Panel = null
	Global.set_mouse_state(Global.mouse.MOVEMENT)
	#print_rich("Mouse has exited left section.")
	#Global.stack_info(get_stack())

func _on_right_mouse_entered():
	if Global.Is_Able_To_Turn == true:
		Global.Current_Movement_Panel = RightPanel
		Global.set_mouse_state(Global.mouse.ROTATION)
		#print_rich("Mouse has entered Right section.")
		#Global.stack_info(get_stack())

func _on_right_mouse_exited():
	Global.Current_Movement_Panel = null
	Global.set_mouse_state(Global.mouse.MOVEMENT)
	#print_rich("Mouse has exited right section.")
	#Global.stack_info(get_stack())

func _on_bottom_mouse_entered():
	if Global.Is_Able_To_Turn == true:
		Global.Current_Movement_Panel = BottomPanel
		Global.set_mouse_state(Global.mouse.ROTATION)
		#print_rich("Mouse has entered bottom section.")
		#Global.stack_info(get_stack())

func _on_bottom_mouse_exited():
	Global.Current_Movement_Panel = null
	Global.set_mouse_state(Global.mouse.MOVEMENT)
	#print_rich("Mouse has exited bottom section.")
	#Global.stack_info(get_stack())
