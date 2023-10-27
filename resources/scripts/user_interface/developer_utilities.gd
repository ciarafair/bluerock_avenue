extends CanvasLayer

@onready var fps_counter_label = %FramesPerSecond
@onready var fps_hovering_block_seperator = %VSeparator
@onready var hovering_block_label = %HoveringBlock

@onready var current_active_block_label = %CurrentActiveBlock
@onready var current_active_event_label = %CurrentActiveEvent
@onready var current_time_label = %CurrentTime
@onready var current_room_label = %CurrentRoom

@onready var position_collection = %PlayerPosition
@onready var x_position_label: Label = %XPosition
@onready var y_position_label: Label = %YPosition
@onready var z_position_label: Label = %ZPosition

@onready var rotation_collection = %PlayerRotation
@onready var x_rotation_label = %XRotation
@onready var y_rotation_label = %YRotation
@onready var z_rotation_label = %ZRotation

const maxLength: int = 5

func truncateString(inputString: String) -> String:
	if inputString.length() > maxLength:
		return inputString.left(maxLength)
	else:
		return inputString

func fps_counter_info():
	var fps = Engine.get_frames_per_second()
	fps_counter_label.text = "FPS: " + str(fps)

	if Global.Is_Fps_Counter_Visible == true:
		fps_counter_label.set_visible(true)
		return

	if Global.Is_Fps_Counter_Visible == false:
		fps_counter_label.set_visible(false)
		return

func current_time_info():
	current_time_label.text = Global.time_string
	if Global.Is_Current_Time_Info_Visible == true:
		current_time_label.set_visible(true)

	if Global.Is_Current_Time_Info_Visible == false:
		current_time_label.set_visible(false)

func current_room_info():
	if Global.Current_Room != null:
		current_room_label.text = "Current room: " + str(Global.Current_Room.name)

	if Global.Is_Current_Room_Info_Visible == true:
		current_room_label.set_visible(true)

	if Global.Is_Current_Room_Info_Visible == false:
		current_room_label.set_visible(false)

func player_info():
	var originalRotationX = str(Global.Loaded_Player.position.x)
	var originalRotationY = str(Global.Loaded_Player.position.y)
	var originalRotationZ = str(Global.Loaded_Player.position.z)

	var originalPositionX = str(Global.Loaded_Player.rotation_degrees.x)
	var originalPositionY = str(Global.Loaded_Player.rotation_degrees.y)
	var originalPositionZ = str(Global.Loaded_Player.rotation_degrees.z)

	var truncatedRotationX = truncateString(originalRotationX)
	var truncatedRotationY = truncateString(originalRotationY)
	var truncatedRotationZ = truncateString(originalRotationZ)

	var truncatedPositionX = truncateString(originalPositionX)
	var truncatedPositionY = truncateString(originalPositionY)
	var truncatedPositionZ = truncateString(originalPositionZ)


	if Global.Is_Player_Info_Visible == true:
		position_collection.set_visible(true)
		rotation_collection.set_visible(true)

		if Global.Loaded_Player != null:
			x_position_label.text = truncatedPositionX
			y_position_label.text = truncatedPositionY
			z_position_label.text = truncatedPositionZ

			x_rotation_label.text = truncatedRotationX
			y_rotation_label.text = truncatedRotationY
			z_rotation_label.text = truncatedRotationZ

	if Global.Is_Player_Info_Visible == false:
		position_collection.set_visible(false)
	else:
		rotation_collection.set_visible(true)

func hovering_block_info():
	fps_hovering_block_seperator_manager()
	if Global.Is_Hovering_Block_Visible == true:
		hovering_block_label.set_visible(true)

		if Global.Hovering_Block != null:
			hovering_block_label.text = "Hovering: " + str(Global.Hovering_Block.name)

		if Global.Hovering_Block == null:
			hovering_block_label.text = "Hovering: Null"

	if Global.Is_Hovering_Block_Visible == false:
		hovering_block_label.set_visible(false)
	else:
		hovering_block_label.set_visible(true)

func fps_hovering_block_seperator_manager():
	if hovering_block_label.visible == true && fps_counter_label.visible == true:
		fps_hovering_block_seperator.set_visible(true)

	if hovering_block_label.visible == false:
		fps_hovering_block_seperator.set_visible(false)

	if fps_counter_label.visible == false:
		fps_hovering_block_seperator.set_visible(false)

func current_active_block_info():
	if Global.Is_Current_Active_Block_Visible == true:
		current_active_block_label.set_visible(true)

		if Global.Current_Active_Block != null:
			current_active_block_label.text = "Current block: " + str(Global.Current_Active_Block.name)

		if Global.Current_Active_Block == null:
			current_active_block_label.text = "Current block: Null"

	if Global.Is_Current_Active_Block_Visible == false:
		current_active_block_label.set_visible(false)
	else:
		current_active_block_label.set_visible(true)

func current_active_event_info():
	if Global.Is_Current_Active_Event_Visible == true:
		current_active_event_label.set_visible(true)

		if Global.Current_Event != "":
			current_active_event_label.text = "Current event: " + str(Global.Current_Event)

		if Global.Current_Event == "":
			current_active_event_label.text = "Current event: Null"

	if Global.Is_Current_Active_Event_Visible == false:
		current_active_event_label.set_visible(false)
	else:
		current_active_event_label.set_visible(true)

func _process(_delta):

	fps_counter_info()

	if Global.Is_Game_Active == true:
		player_info()
		hovering_block_info()
		current_active_block_info()
		current_active_event_info()
		current_time_info()
		current_room_info()

	if Global.Is_Game_Active == false:
		position_collection.set_visible(false)
		rotation_collection.set_visible(false)
		fps_hovering_block_seperator.set_visible(false)
		hovering_block_label.set_visible(false)
		current_active_block_label.set_visible(false)
		current_active_event_label.set_visible(false)
		current_time_label.set_visible(false)
		current_room_label.set_visible(false)
