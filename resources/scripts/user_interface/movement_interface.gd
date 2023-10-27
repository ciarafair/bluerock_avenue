extends CanvasLayer

@onready var DOWN_ARROW_SPRITE = load("res://Resources/sprites/down_arrow.png")
@onready var LEFT_ARROW_SPRITE = load("res://Resources/sprites/left_arrow.png")
@onready var RIGHT_ARROW_SPRITE = load("res://Resources/sprites/right_arrow.png")


func _on_left_mouse_entered():
	if Global.Is_Able_To_Turn == true && Global.Is_Pause_Menu_Open == false:
		Input.set_custom_mouse_cursor(LEFT_ARROW_SPRITE)
		Global.Is_Hovering_Over_Left_Movement_Panel = true
		#print_debug("Mouse has entered left section.")

func _on_left_mouse_exited():
	Input.set_custom_mouse_cursor(null)
	Global.Is_Hovering_Over_Left_Movement_Panel = false
	#print_debug("Mouse has exited left section.")

func _on_right_mouse_entered():
	if Global.Is_Able_To_Turn == true && Global.Is_Pause_Menu_Open == false:
		Input.set_custom_mouse_cursor(RIGHT_ARROW_SPRITE)
		Global.Is_Hovering_Over_Right_Movement_Panel = true
		#print_debug("Mouse has entered Right section.")

func _on_right_mouse_exited():
	Input.set_custom_mouse_cursor(null)
	Global.Is_Hovering_Over_Right_Movement_Panel = false
	#print_debug("Mouse has exited right section.")

func _on_bottom_mouse_entered():
	if Global.Is_Able_To_Turn == true && Global.Is_Pause_Menu_Open == false:
		Input.set_custom_mouse_cursor(DOWN_ARROW_SPRITE)
		Global.Is_Hovering_Over_Bottom_Movement_Panel = true
		#print_debug("Mouse has entered bottom section.")

func _on_bottom_mouse_exited():
	Input.set_custom_mouse_cursor(null)
	Global.Is_Hovering_Over_Bottom_Movement_Panel = false
	#print_debug("Mouse has exited bottom section.")
