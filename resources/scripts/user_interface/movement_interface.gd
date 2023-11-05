extends CanvasLayer

@onready var BottomPanel = $Bottom
@onready var LeftPanel = $Left
@onready var RightPanel = $Right

func _on_left_mouse_entered():
	if Global.Is_Able_To_Turn == true:
		Global.Mouse_State = 3
		Global.Current_Movement_Panel = LeftPanel
		#print_debug("Mouse has entered left section.")

func _on_left_mouse_exited():
	Global.Current_Movement_Panel = null
	Global.Mouse_State = 1
	#print_debug("Mouse has exited left section.")

func _on_right_mouse_entered():
	if Global.Is_Able_To_Turn == true:
		Global.Current_Movement_Panel = RightPanel
		Global.Mouse_State = 3
		#print_debug("Mouse has entered Right section.")

func _on_right_mouse_exited():
	Global.Current_Movement_Panel = null
	Global.Mouse_State = 1
	#print_debug("Mouse has exited right section.")

func _on_bottom_mouse_entered():
	if Global.Is_Able_To_Turn == true:
		Global.Current_Movement_Panel = BottomPanel
		Global.Mouse_State = 3
		#print_debug("Mouse has entered bottom section.")

func _on_bottom_mouse_exited():
	Global.Current_Movement_Panel = null
	Global.Mouse_State = 1
	#print_debug("Mouse has exited bottom section.")
