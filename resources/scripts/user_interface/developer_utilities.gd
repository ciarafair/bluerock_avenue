extends CanvasLayer

@onready var fps_counter_label: Label = %FramesPerSecond
@onready var vseperator_one: VSeparator = %VSeparator
@onready var hovering_block_label: Label = %HoveringBlock
@onready var vseperator_two: VSeparator = %VSeparator2
@onready var current_time_label: Label = %CurrentTime

@onready var current_active_block_label: Label = %CurrentActiveBlock
@onready var current_active_event_label: Label = %CurrentActiveEvent
@onready var player_current_room_label: Label = %CurrentRoom

@onready var monster_current_room_label: Label = %MonsterCurrentRoom
@onready var monster_current_stage_label: Label = %MonsterCurrentStage

@onready var position_collection = %PlayerPosition
@onready var x_position_label: Label = %XPosition
@onready var y_position_label: Label = %YPosition
@onready var z_position_label: Label = %ZPosition

@onready var rotation_collection = %PlayerRotation
@onready var x_rotation_label: Label = %XRotation
@onready var y_rotation_label: Label = %YRotation
@onready var z_rotation_label: Label= %ZRotation

const maxLength: int = 5

func truncateString(inputString: String) -> String:
	if inputString.length() > maxLength:
		return inputString.left(maxLength)
	else:
		return inputString

func fps_counter_info():
	var fps = Engine.get_frames_per_second()
	fps_counter_label.text = "FPS: " + str(fps)

	if Global.Settings_Data.Is_Fps_Counter_Visible == true:
		fps_counter_label.set_visible(true)
		return

	if Global.Settings_Data.Is_Fps_Counter_Visible == false:
		fps_counter_label.set_visible(false)
		return

func current_time_info():
	current_time_label.text = Global.Time_String
	if Global.Settings_Data.Is_Current_Time_Info_Visible == true:
		current_time_label.set_visible(true)

	if Global.Settings_Data.Is_Current_Time_Info_Visible == false:
		current_time_label.set_visible(false)

func player_current_room_info():
	if Global.Current_Room != null:
		player_current_room_label.text = "Current room: " + str(Global.Current_Room.name)

	if Global.Settings_Data.Is_Player_Current_Room_Info_Visible == true:
		player_current_room_label.set_visible(true)

	if Global.Settings_Data.Is_Player_Current_Room_Info_Visible == false:
		player_current_room_label.set_visible(false)

func monster_current_stage_info():
	monster_current_stage_label.text = "Monster's current stage: " + str(Global.Monster_Current_Stage)

	if Global.Settings_Data.Is_Monster_Info_Visible == true:
		monster_current_stage_label.set_visible(true)

	if Global.Settings_Data.Is_Monster_Info_Visible == false:
		monster_current_stage_label.set_visible(false)

func monster_current_room_info():
	if Global.Monster_Current_Room != null:
		monster_current_room_label.text = "Monster's current room: " + str(Global.Monster_Current_Room.name)
	else:
		monster_current_room_label.text = "Monster's current room: null"

	if Global.Settings_Data.Is_Monster_Info_Visible == true:
		monster_current_room_label.set_visible(true)

	if Global.Settings_Data.Is_Monster_Info_Visible == false:
		monster_current_room_label.set_visible(false)

func player_info():
	var originalPositionX = str(Global.Loaded_Player.position.x)
	var originalPositionY = str(Global.Loaded_Player.position.y)
	var originalPositionZ = str(Global.Loaded_Player.position.z)

	var truncatedPositionX = truncateString(originalPositionX)
	var truncatedPositionY = truncateString(originalPositionY)
	var truncatedPositionZ = truncateString(originalPositionZ)

	var originalRotationX = str(Global.Loaded_Player.rotation_degrees.x)
	var originalRotationY = str(Global.Loaded_Player.rotation_degrees.y)
	var originalRotationZ = str(Global.Loaded_Player.rotation_degrees.z)

	var truncatedRotationX = truncateString(originalRotationX)
	var truncatedRotationY = truncateString(originalRotationY)
	var truncatedRotationZ = truncateString(originalRotationZ)

	if Global.Settings_Data.Is_Player_Info_Visible == true:
		position_collection.set_visible(true)
		rotation_collection.set_visible(true)

		if Global.Loaded_Player != null:
			x_position_label.text = truncatedPositionX
			y_position_label.text = truncatedPositionY
			z_position_label.text = truncatedPositionZ

			x_rotation_label.text = truncatedRotationX
			y_rotation_label.text = truncatedRotationY
			z_rotation_label.text = truncatedRotationZ

	if Global.Settings_Data.Is_Player_Info_Visible == false:
		rotation_collection.set_visible(false)
		position_collection.set_visible(false)
	else:
		rotation_collection.set_visible(true)
		position_collection.set_visible(true)

func hovering_block_info():
	if Global.Settings_Data.Is_Hovering_Block_Visible == true:
		hovering_block_label.set_visible(true)

		if Global.Hovering_Block != null:
			hovering_block_label.text = "Hovering: " + str(Global.Hovering_Block.name)

		if Global.Hovering_Block == null:
			hovering_block_label.text = "Hovering: Null"

	if Global.Settings_Data.Is_Hovering_Block_Visible == false:
		hovering_block_label.set_visible(false)
	else:
		hovering_block_label.set_visible(true)

func v_seperator_manager():
	if current_time_label.visible == true:
		if fps_counter_label.visible == true && hovering_block_label.visible == false or hovering_block_label.visible == true:
			vseperator_two.set_visible(true)
	else:
		vseperator_two.set_visible(false)

	if hovering_block_label.visible == true:
		if fps_counter_label.visible == true:
			vseperator_one.set_visible(true)
		else:
			vseperator_one.set_visible(false)
	else:
		vseperator_one.set_visible(false)

func current_active_block_info():
	if Global.Settings_Data.Is_Current_Active_Block_Visible == true:
		current_active_block_label.set_visible(true)

		if Global.Current_Active_Block != null:
			current_active_block_label.text = "Current block: " + str(Global.Current_Active_Block.name)

		if Global.Current_Active_Block == null:
			current_active_block_label.text = "Current block: Null"

	if Global.Settings_Data.Is_Current_Active_Block_Visible == false:
		current_active_block_label.set_visible(false)
	else:
		current_active_block_label.set_visible(true)

func current_active_event_info():
	if Global.Settings_Data.Is_Current_Active_Event_Visible == true:
		current_active_event_label.set_visible(true)

		if Global.Current_Event != "":
			current_active_event_label.text = "Current event: " + str(Global.Current_Event)

		if Global.Current_Event == "":
			current_active_event_label.text = "Current event: Null"

	if Global.Settings_Data.Is_Current_Active_Event_Visible == false:
		current_active_event_label.set_visible(false)
	else:
		current_active_event_label.set_visible(true)

func _process(_delta):

	fps_counter_info()

	if Global.Is_Game_Active == true:
		v_seperator_manager()
		player_info()
		hovering_block_info()
		current_active_block_info()
		current_active_event_info()
		current_time_info()
		player_current_room_info()
		monster_current_room_info()
		monster_current_stage_info()

	if Global.Is_Game_Active == false:
		position_collection.set_visible(false)
		rotation_collection.set_visible(false)
		vseperator_one.set_visible(false)
		vseperator_two.set_visible(false)
		hovering_block_label.set_visible(false)
		current_active_block_label.set_visible(false)
		current_active_event_label.set_visible(false)
		current_time_label.set_visible(false)
		player_current_room_label.set_visible(false)
		monster_current_room_label.set_visible(false)
		monster_current_stage_label.set_visible(false)