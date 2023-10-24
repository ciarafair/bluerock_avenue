extends Node


var STARTUP_TIMER: Timer = Timer.new()
var WaitTimer: Timer = Timer.new()
var IS_HOLDING_SPACE: bool = false

func _ready():
	self.add_child(STARTUP_TIMER)

func on_wait_timer_timeout():
	Global.Is_Timed_Out = false
	pass

func _unhandled_input(_event: InputEvent):
	if Global.Is_Game_Active == true:
		if Input.is_action_just_released("flashlight"):
			if EventManager.IS_FLASHLIGHT_TOGGLEABLE == true:
				Global.Is_Flashlight_On = !Global.Is_Flashlight_On
			else:
				print_debug("Flashlight is not toggleable in this location.")

		if Input.is_action_just_released("pause_menu_toggle"):
			Global.Is_Pause_Menu_Open = !Global.Is_Pause_Menu_Open

		if Global.Current_Event == "":
			if Global.Is_In_Animation != true:
				if Global.Is_Clickable == true:
					if Global.Hovering_Block != null && Global.Is_Hovering_Over_Left_Movement_Panel == false && Global.Is_Hovering_Over_Bottom_Movement_Panel == false && Global.Is_Hovering_Over_Right_Movement_Panel == false:
						if Input.is_action_just_released("mouse_button_1"):
							print_debug("Clicking")
							SignalManager.activate_block.emit(Global.Hovering_Block) # EventManager.gd
							return

				if Input.is_action_just_released("mouse_button_2"):
					SignalManager.deactivate_block.emit(Global.Current_Active_Block) # EventManager.gd
					return

				if Global.Is_Hovering_Over_Bottom_Movement_Panel == true:
					if Input.is_action_just_released("mouse_button_1"):
						SignalManager.turn_180_degrees.emit() # Player.gd
						return

				if Global.Is_Hovering_Over_Left_Movement_Panel == true:
					if Input.is_action_just_released("mouse_button_1"):
						SignalManager.turn_positive_90_degrees.emit() # Player.gd
						return

				if Global.Is_Hovering_Over_Right_Movement_Panel == true:
					if Input.is_action_just_released("mouse_button_1"):
						SignalManager.turn_negative_90_degrees.emit() # Player.gd
						return

		if Global.Current_Event == "door":
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
					if Global.Current_Active_Block.Door_Number != null:
						Global.Current_Room.set_visible(false)
						SignalManager.stop_event.emit()
						Global.Current_Event = ""
						SignalManager.leave_room.emit(Global.Current_Active_Block.Door_Number)
						return

		if Global.Current_Event == "window":
			if Input.is_action_just_released("dev_open_window"):
				if Global.Is_Window_Being_Opened == false && Global.Is_Window_Open == false:
					SignalManager.open_window.emit()

			if Input.is_action_just_released("space_bar"):
				if Global.Is_Window_Being_Opened == true or Global.Is_Window_Open == true:
					SignalManager.close_window.emit()

			if Input.is_action_just_released("mouse_button_2"):
				SignalManager.deactivate_block.emit(Global.Current_Active_Block) # EventManager.gd
				Global.Current_Event = ""
				return

