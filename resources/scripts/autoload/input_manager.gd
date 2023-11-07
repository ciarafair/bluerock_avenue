extends Node


var STARTUP_TIMER: Timer = Timer.new()
var WaitTimer: Timer = Timer.new()
var IsHoldingSpace: bool = false
var IsHoldingShift: bool = false

func _ready():
	self.add_child(STARTUP_TIMER)

func on_wait_timer_timeout():
	Global.Is_Timed_Out = false
	pass

func manage_normal_input():
	if Global.Hovering_Block != null:
		if Global.Is_Clickable == true:
			if Global.Mouse_State == 1:
				if Input.is_action_just_released("mouse_button_1"):
					SignalManager.activate_block.emit(Global.Hovering_Block) # EventManager.gd
					return

			if Global.Mouse_State == 2:
				if Input.is_action_just_released("mouse_button_1"):
					if Global.Hovering_Block.BlockDialoguePath != null:
						print_debug("Insert dialogue here")
						SignalManager.begin_dialogue.emit(Global.Hovering_Block, Global.Hovering_Block.BlockDialoguePath)
						return

	if Input.is_action_just_released("mouse_button_2"):
		SignalManager.deactivate_block.emit(Global.Game_Data.Current_Active_Block) # EventManager.gd
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
			SignalManager.open_window.emit(Global.Game_Data.Current_Active_Block)

	if Input.is_action_just_released("space_bar"):
		if Global.Is_Window_Being_Opened == true && Global.Is_Window_Being_Closed == false or Global.Is_Window_Open == true && Global.Is_Window_Being_Closed == false:
			SignalManager.close_window.emit(Global.Game_Data.Current_Active_Block)

	if Input.is_action_just_released("mouse_button_2"):
			SignalManager.deactivate_block.emit(Global.Game_Data.Current_Active_Block) # EventManager.gd
			Global.Game_Data.Current_Event = ""
			return

func manage_door_input():
	if IsHoldingShift == false:
		if Input.is_action_pressed("manage_door_status"):
			if IsHoldingSpace == true && Global.Is_In_Animation == false:
				IsHoldingSpace = false
				SignalManager.close_door.emit()

		if Input.is_action_just_released("manage_door_status"):
			if IsHoldingSpace == false:
				IsHoldingSpace = true
				SignalManager.open_door.emit()
	else:
		SignalManager.close_door.emit()

	if IsHoldingSpace == false:
		if Input.is_action_pressed("manage_door_listening"):
				if IsHoldingShift == false && Global.Is_In_Animation == false:
					IsHoldingShift = true
					SignalManager.player_camera_listen.emit()

		if Input.is_action_just_released("manage_door_listening"):
			if IsHoldingShift == true:
				IsHoldingShift = false
				SignalManager.reset_player_camera.emit()
	else:
			SignalManager.reset_player_camera.emit()

	if Input.is_action_just_released("mouse_button_2"):
		SignalManager.deactivate_block.emit(Global.Game_Data.Current_Active_Block) # EventManager.gd
		return

	if Global.Is_Door_Opened == true:
		if Input.is_action_just_released("mouse_button_1"):
			#print_debug("Left mouse button pressed.")
			SignalManager.stop_event.emit()
			IsHoldingSpace = false
			if Global.Game_Data.Current_Room.RoomNumber == Global.Game_Data.Current_Active_Block.ConnectedRoomOne:
				#print_debug("Moving to room #" + str(Global.Current_Active_Block.ConnectedRoomTwo))
				Global.Game_Data.Current_Room.set_visible(false)
				Global.Game_Data.Current_Event = ""
				SignalManager.move_to_room.emit(Global.Loaded_Game_World, Global.Game_Data.Current_Active_Block.ConnectedRoomTwo)
				return
			elif Global.Game_Data.Current_Room.RoomNumber == Global.Game_Data.Current_Active_Block.ConnectedRoomTwo:
				#print_debug("Moving to room #" + str(Global.Current_Active_Block.ConnectedRoomTwo))
				Global.Game_Data.Current_Room.set_visible(false)
				Global.Game_Data.Current_Event = ""
				SignalManager.move_to_room.emit(Global.Loaded_Game_World, Global.Game_Data.Current_Active_Block.ConnectedRoomOne)
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

		if Global.Mouse_State != 3:
			if Input.is_action_pressed("select_dialogue"):
					Global.Mouse_State = 2

			if Input.is_action_just_released("select_dialogue"):
				Global.Mouse_State = 1

		if Global.Game_Data.Current_Event == "":
			if Global.Is_In_Animation != true:
				manage_normal_input()

		if Global.Game_Data.Current_Event == "door":
			manage_door_input()

		if Global.Game_Data.Current_Event == "window":
			manage_window_input()

