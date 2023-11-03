extends Node


var STARTUP_TIMER: Timer = Timer.new()
var WaitTimer: Timer = Timer.new()
var IS_HOLDING_SPACE: bool = false

func _ready():
	self.add_child(STARTUP_TIMER)

func on_wait_timer_timeout():
	Global.Is_Timed_Out = false
	pass

func manage_normal_input():
	if Global.Hovering_Block != null:
		if Global.Is_Clickable == true:
			if Global.Mouse_State == 0:
				if Input.is_action_just_released("mouse_button_1"):
					SignalManager.activate_block.emit(Global.Hovering_Block) # EventManager.gd
					return

			if Global.Mouse_State == 2:
				if Input.is_action_just_released("mouse_button_1"):
					print_debug("Insert dialogue here")
					return

	if Input.is_action_just_released("mouse_button_2"):
		SignalManager.deactivate_block.emit(Global.Current_Active_Block) # EventManager.gd
		return

	if Global.Current_Movement_Panel != null:
		if Global.Current_Movement_Panel.name == "Bottom":
			if Input.is_action_just_released("mouse_button_1"):
				SignalManager.turn_180_degrees.emit() # Player.gd
				return

		if Global.Current_Movement_Panel.name == "Left":
			if Input.is_action_just_released("mouse_button_1"):
				SignalManager.turn_positive_90_degrees.emit() # Player.gd
				return

		if Global.Current_Movement_Panel.name == "Right":
			if Input.is_action_just_released("mouse_button_1"):
				SignalManager.turn_negative_90_degrees.emit() # Player.gd
				return


func manage_window_input():
	if Input.is_action_just_released("dev_open_window"):
		if Global.Is_Window_Being_Opened == false && Global.Is_Window_Open == false:
			SignalManager.open_window.emit(Global.Current_Active_Block)

	if Input.is_action_just_released("space_bar"):
		if Global.Is_Window_Being_Opened == true && Global.Is_Window_Being_Closed == false or Global.Is_Window_Open == true && Global.Is_Window_Being_Closed == false:
			SignalManager.close_window.emit(Global.Current_Active_Block)

	if Input.is_action_just_released("mouse_button_2"):
			SignalManager.deactivate_block.emit(Global.Current_Active_Block) # EventManager.gd
			Global.Current_Event = ""
			return

func manage_door_input():
	if Input.is_action_pressed("space_bar"):
		if IS_HOLDING_SPACE == false && Global.Is_In_Animation == false:
			IS_HOLDING_SPACE = true
			SignalManager.open_door.emit()

	if Input.is_action_just_released("space_bar"):
		if IS_HOLDING_SPACE == true:
			IS_HOLDING_SPACE = false
			SignalManager.close_door.emit()

	if Input.is_action_just_released("mouse_button_2"):
		SignalManager.deactivate_block.emit(Global.Current_Active_Block) # EventManager.gd
		return

	if Global.Is_Door_Opened == true:
		if Input.is_action_just_released("mouse_button_1"):
			#print_debug("Left mouse button pressed.")
			SignalManager.stop_event.emit()
			IS_HOLDING_SPACE = false
			if Global.Current_Room.RoomNumber == Global.Current_Active_Block.ConnectedRoomOne:
				#print_debug("Moving to room #" + str(Global.Current_Active_Block.ConnectedRoomTwo))
				Global.Current_Room.set_visible(false)
				Global.Current_Event = ""
				SignalManager.move_to_room.emit(Global.Current_Active_Block.ConnectedRoomTwo)
				return
			elif Global.Current_Room.RoomNumber == Global.Current_Active_Block.ConnectedRoomTwo:
				#print_debug("Moving to room #" + str(Global.Current_Active_Block.ConnectedRoomTwo))
				Global.Current_Room.set_visible(false)
				Global.Current_Event = ""
				SignalManager.move_to_room.emit(Global.Current_Active_Block.ConnectedRoomOne)
				return
			else:
				print_debug("Could not find room number out of either ConnectedRoomOne or ConnectedRoomTwo.")

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Global.Is_Window_Focused == true:
		SignalManager.mouse_movement.emit(event.relative)

	if Global.Is_Game_Active == true:
		if Input.is_action_just_released("flashlight"):
			if EventManager.IS_FLASHLIGHT_TOGGLEABLE == true:
				Global.Is_Flashlight_On = !Global.Is_Flashlight_On
			else:
				print_debug("Flashlight is not toggleable in this location.")

		if Input.is_action_just_released("pause_menu_toggle"):
			Global.Is_Pause_Menu_Open = !Global.Is_Pause_Menu_Open

		if Input.is_action_pressed("select_dialogue"):
			Global.Mouse_State = 2

		if Input.is_action_just_released("select_dialogue"):
			Global.Mouse_State = 0

		if Global.Current_Event == "":
			if Global.Is_In_Animation != true:
				manage_normal_input()

		if Global.Current_Event == "door":
			manage_door_input()

		if Global.Current_Event == "window":
			manage_window_input()

