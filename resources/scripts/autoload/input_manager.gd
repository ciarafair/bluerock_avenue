extends Node

var IsHoldingSpace: bool = false
var IsHoldingShift: bool = false

func manage_normal_input():
	if Global.Hovering_Interactable != null:
		if Input.is_action_just_released("mouse_button_1"):
			if Global.CurrentMouseState == 1:
				Global.Hovering_Interactable.activate()
				return

	if Global.Hovering_Block != null:
		if Global.Is_Clickable == true:
			if Input.is_action_just_released("mouse_button_1"):

				if Global.CurrentMouseState == 1:
					print_rich("Activating %s"%[Global.Hovering_Block])
					Global.stack_info(get_stack())
					if Global.task_check(Global.Hovering_Block) == {}:
						#print_rich("Activating %s" %[Global.Hovering_Block])
						#Global.stack_info(get_stack())
						Global.Hovering_Block.activate()
						return
					else:
						if Global.DialogueBoxInstance == null:
							SignalManager.load_dialogue_box.emit()
						SignalManager.click_dialogue.emit(Global.task_check(Global.Hovering_Block))
						return

				elif Global.CurrentMouseState == 2:
					if Global.Hovering_Block.BlockDialoguePath != null:
						if Global.DialogueBoxInstance == null:
							SignalManager.load_dialogue_box.emit()
						SignalManager.click_dialogue.emit(Global.stringify_json(Global.Hovering_Block.BlockDialoguePath))
						return

	if Input.is_action_just_released("mouse_button_2"):
		if Global.Game_Data_Instance.Current_Block.BlockParent != null:
			SignalManager.deactivate_block.emit(Global.Game_Data_Instance.Current_Block)
			return

	if Global.CurrentMouseState == 3:
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
	if Input.is_action_just_released("manage_door_status"):
		if Global.Is_Window_Being_Opened == true && Global.Is_Window_Being_Closed == false or Global.Is_Window_Open == true && Global.Is_Window_Being_Closed == false:
			SignalManager.close_window.emit(Global.Game_Data_Instance.Current_Block)

	if Input.is_action_just_released("mouse_button_2"):
			SignalManager.deactivate_block.emit(Global.Game_Data_Instance.Current_Block) # EventManager.gd
			Global.Game_Data_Instance.Current_Event = ""
			return

func manage_door_input():
	if Input.is_action_pressed("manage_door_listening"):
		if Global.Game_Data_Instance.Current_Block.CurrentStatus == 1:
			Global.Game_Data_Instance.Current_Block.check_if_player_is_listening_to_door()
			if Global.Is_In_Animation == false:
				if IsHoldingShift == false:
					Global.Is_Player_Listening_To_Door = true
					IsHoldingShift = true
					SignalManager.player_camera_listen.emit()
					return

	if Input.is_action_just_released("manage_door_listening"):
		if IsHoldingShift == true:
			IsHoldingShift = false
			Global.Is_Player_Listening_To_Door = false
			SignalManager.reset_player_camera.emit()

	if Input.is_action_just_released("mouse_button_1"):
		#print_rich("Left mouse button pressed.")
		#Global.stack_info(get_stack())
		if Global.CurrentMouseState == 1:
			if Global.Hovering_Interactable != null:
				Global.Hovering_Interactable.activate()
				return

	if Input.is_action_just_released("spacebar"):
		IsHoldingSpace = false
		Global.Game_Data_Instance.Current_Block.move_to_other_room()
		return

	if Input.is_action_just_released("mouse_button_2"):
		SignalManager.deactivate_block.emit(Global.Game_Data_Instance.Current_Block) # EventManager.gd
		return

func manage_dev_input():
		if Input.is_action_just_released("spawn_monster"):
			#SignalManager.spawn_monster.emit()
			if Global.Game_Data_Instance.Monster_Current_Stage != 3:
				Global.Game_Data_Instance.Monster_Current_Stage += 1
			elif Global.Game_Data_Instance.Monster_Current_Stage == 3:
				Global.Game_Data_Instance.Monster_Current_Stage = 0

		if Input.is_action_just_released("game_over"):
			SignalManager.game_over.emit()

func manage_mouse_status():
	if Global.CurrentMouseState != Global.mouse.ROTATION:
		if Input.is_action_pressed("select_dialogue"):
			Global.set_mouse_state(Global.mouse.DIALOGUE)

		if Input.is_action_just_released("select_dialogue"):
			Global.set_mouse_state(Global.mouse.MOVEMENT)

func flashlight_check() -> bool:
	for item in Global.Game_Data_Instance.PlayerInventory:
		if item is Flashlight:
			return true
		else:
			pass
	return false

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Global.Is_Window_Focused == true:
		SignalManager.mouse_movement.emit(event.position)

	if Global.Is_Game_Active == true:
		manage_dev_input()
		manage_mouse_status()

		if Global.Game_Data_Instance.Current_Event == "":
			if Global.Is_In_Animation != true:
				manage_normal_input()

		if Global.Game_Data_Instance.Current_Event == "door":
			manage_door_input()

		if Global.Game_Data_Instance.Current_Event == "window":
			manage_window_input()

		if flashlight_check() == true:
			if Input.is_action_just_released("flashlight"):
				if EventManager.IS_FLASHLIGHT_TOGGLEABLE == true:
					Global.Game_Data_Instance.Is_Flashlight_On = !Global.Game_Data_Instance.Is_Flashlight_On
				else:
					printerr("Flashlight is not toggleable in this location.")

		if Input.is_action_just_released("pause_menu_toggle"):
			Global.Is_Pause_Menu_Open = !Global.Is_Pause_Menu_Open

		if Input.is_action_just_released("ui_accept"):
			SignalManager.manage_dialogue.emit()
