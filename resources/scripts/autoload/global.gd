extends Node

var Settings_Data: SettingsData
var Game_Data: GameData

# Meta Data - Stays in this script as it does not need to be saved
var Loaded_Player: Node3D = null
var Loaded_Game_World: Node3D = null
var Loaded_Options_Menu: CanvasLayer = null
var Loaded_Main_Menu: CanvasLayer = null
var Loaded_Pause_Menu: CanvasLayer = null

var Is_Window_Focused := true
var Current_Track: String = ""
var Mouse_State: int = 1
var Is_Music_Playing: bool = false
var Is_Game_Active: bool = false
var Is_Pause_Menu_Open: bool = false
var Is_Clickable: bool = false
var Is_In_Animation: bool = false
var Is_Timed_Out: bool = false
var Current_Movement_Panel: Panel = null
var MousePosition2D: Vector2
var ScreenCentre: Vector2i
var SpaceState: PhysicsDirectSpaceState3D
var RAYCAST_COLLISION_OBJECT
var Hovering_Block: Block
var FLASHLIGHT_RAY_ARRAY: Array = []
var Is_Window_Being_Opened: bool = false
var Is_Window_Open: bool = false
var Is_Door_Opened: bool = false
var Is_Window_Being_Closed: bool = false
var Is_Able_To_Turn: bool = false

# Game Data - move to seperate instance
var Is_Flashlight_On: bool = false

func on_tween_finished():
	#print_debug("Tween completed")
	Global.Is_In_Animation = false
	SignalManager.animation_finished.emit()

@onready var EyeCursor = preload("res://resources/textures/mouse_cursors/eye.png")
@onready var DialogueCursor = preload("res://resources/textures/mouse_cursors/speech_bubble.png")
@onready var DownArrowCursor = preload("res://resources/textures/mouse_cursors/down_arrow.png")
@onready var LeftArrowCursor = preload("res://resources/textures/mouse_cursors/left_arrow.png")
@onready var RightArrowCursor = preload("res://resources/textures/mouse_cursors/right_arrow.png")

func manage_mouse_cursor():
	if Is_Game_Active == true:
		if Mouse_State == 1:
			if Hovering_Block != null:
				Input.set_custom_mouse_cursor(EyeCursor)
				return
			else:
				Input.set_custom_mouse_cursor(null)
				return

		elif Mouse_State == 2:
			if Hovering_Block != null:
				if Hovering_Block.BlockDialoguePath == null:
					Input.set_custom_mouse_cursor(null)
					return
				else:
					Input.set_custom_mouse_cursor(DialogueCursor)
					return
			else:
				Input.set_custom_mouse_cursor(null)

		if Is_Game_Active == false:
			Input.set_custom_mouse_cursor(null)

		elif Mouse_State == 3:
			if Current_Movement_Panel != null:
				if Current_Movement_Panel.name == "Bottom":
					Input.set_custom_mouse_cursor(DownArrowCursor)
					return
				elif Current_Movement_Panel.name == "Right":
					Input.set_custom_mouse_cursor(RightArrowCursor)
					return
				elif Current_Movement_Panel.name == "Left":
					Input.set_custom_mouse_cursor(LeftArrowCursor)
					return
			else:
				Input.set_custom_mouse_cursor(null)
				return

	Input.set_custom_mouse_cursor(null)
	return

const Settings_File_Path: String = "res://settings.json"
var Settings_Dictionary: Dictionary = {}

func verify_settings_file_directory(path: String):
	if FileAccess.file_exists(path):
		SignalManager.load_settings_data.emit()
		return
	else:
		Global.Settings_Data = SettingsData.new()
		var file = FileAccess.open(path, FileAccess.WRITE)

		var default_data = {
			"developer_settings": {
				"Is_Current_Active_Block_Visible": Settings_Data.Is_Current_Active_Block_Visible,
				"Is_Current_Active_Event_Visible": Settings_Data.Is_Current_Active_Event_Visible,
				"Is_Current_Time_Info_Visible": Settings_Data.Is_Current_Time_Info_Visible,
				"Is_Fps_Counter_Visible": Settings_Data.Is_Fps_Counter_Visible,
				"Is_Hovering_Block_Visible": Settings_Data.Is_Hovering_Block_Visible,
				"Is_Monster_Info_Visible": Settings_Data.Is_Monster_Info_Visible,
				"Is_Player_Current_Room_Info_Visible": Settings_Data.Is_Player_Current_Room_Info_Visible,
				"Is_Player_Info_Visible": Settings_Data.Is_Player_Info_Visible,
				"Is_Monster_Active": Game_Data.Is_Monster_Active
			},
			"volume_settings": {
				"Master_Volume_Setting": Settings_Data.Master_Volume_Setting,
				"Music_Volume_Setting": Settings_Data.Music_Volume_Setting,
				"SFX_Volume_Setting": Settings_Data.SFX_Volume_Setting
			},
			"general_settings": {
				"Mouse_Sensitivity": Settings_Data.Mouse_Sensitivity,
				"Is_Overlay_Effect_Enabled": Settings_Data.Is_Overlay_Effect_Enabled,
				"Selected_Resolution_Index": Settings_Data.Selected_Resolution_Index
			}
		}

		Settings_Dictionary.merge(default_data, true)
		var json_string = JSON.stringify(Settings_Dictionary, "\t")
		file.store_string(json_string)
		file.close()
		return

func save_developer_settings():
	print_debug("Saving developer settings.")

	var data = {
		"developer_settings":{
			"Is_Fps_Counter_Visible" = Settings_Data.Is_Fps_Counter_Visible,
			"Is_Player_Info_Visible" = Settings_Data.Is_Player_Info_Visible,
			"Is_Hovering_Block_Visible" = Settings_Data.Is_Hovering_Block_Visible,
			"Is_Current_Active_Block_Visible" = Settings_Data.Is_Current_Active_Block_Visible,
			"Is_Current_Active_Event_Visible" = Settings_Data.Is_Current_Active_Event_Visible,
			"Is_Current_Time_Info_Visible" = Settings_Data.Is_Current_Time_Info_Visible,
			"Is_Player_Current_Room_Info_Visible" = Settings_Data.Is_Player_Current_Room_Info_Visible,
			"Is_Monster_Info_Visible" = Settings_Data.Is_Monster_Info_Visible,
			"Is_Monster_Active" = Game_Data.Is_Monster_Active
		}
	}
	Settings_Dictionary.merge(data, true)

func save_volume_settings():
	print_debug("Saving volume settings")

	var data: Dictionary = {
		"volume_settings":{
			"Master_Volume_Setting" = Settings_Data.Master_Volume_Setting,
			"Music_Volume_Setting" = Settings_Data.Music_Volume_Setting,
			"SFX_Volume_Setting" = Settings_Data.SFX_Volume_Setting
		}
	}
	Settings_Dictionary.merge(data, true)

func save_general_settings():
	print_debug("Saving general settings")

	var data: Dictionary = {
		"general_settings": {
			"Mouse_Sensitivity": Settings_Data.Mouse_Sensitivity,
			"Is_Overlay_Effect_Enabled": Settings_Data.Is_Overlay_Effect_Enabled,
			"Selected_Resolution_Index": Settings_Data.Selected_Resolution_Index
		}
	}
	Settings_Dictionary.merge(data, true)

func on_save_settings_data():
	print_debug("Saving settings data")
	var file = FileAccess.open(Settings_File_Path, FileAccess.WRITE)
	if file == null:
		push_warning(str(FileAccess.get_open_error()))
		return

	save_developer_settings()
	save_volume_settings()
	save_general_settings()

	var json_string = JSON.stringify(Settings_Dictionary, "\t")
	file.store_string(json_string)
	file.close()
	return

func set_window_resolution(index: int):
	if index == 0:
		Global.Settings_Data.Current_Window_Size = Vector2i(1920,1080)
		Global.Settings_Data.Selected_Resolution_Index = 0
		get_window().size = Global.Settings_Data.Current_Window_Size

	if index == 1:
		Global.Settings_Data.Current_Window_Size = Vector2i(1600,900)
		Global.Settings_Data.Selected_Resolution_Index = 1
		get_window().size = Global.Settings_Data.Current_Window_Size

	if index == 2:
		Global.Settings_Data.Current_Window_Size = Vector2i(1280,720)
		Global.Settings_Data.Selected_Resolution_Index = 2
		get_window().size = Global.Settings_Data.Current_Window_Size

func load_settings_data(parsed_data: Dictionary):
	Settings_Data.Mouse_Sensitivity = parsed_data.general_settings.Mouse_Sensitivity
	Settings_Data.Is_Overlay_Effect_Enabled = parsed_data.general_settings.Is_Overlay_Effect_Enabled
	Settings_Data.Selected_Resolution_Index = parsed_data.general_settings.Selected_Resolution_Index

	Settings_Data.Master_Volume_Setting = parsed_data.volume_settings.Master_Volume_Setting
	Settings_Data.Music_Volume_Setting = parsed_data.volume_settings.Music_Volume_Setting
	Settings_Data.SFX_Volume_Setting = parsed_data.volume_settings.SFX_Volume_Setting

	Settings_Data.Is_Monster_Info_Visible = parsed_data.developer_settings.Is_Monster_Info_Visible
	Settings_Data.Is_Fps_Counter_Visible = parsed_data.developer_settings.Is_Fps_Counter_Visible
	Settings_Data.Is_Player_Info_Visible = parsed_data.developer_settings.Is_Player_Info_Visible
	Settings_Data.Is_Hovering_Block_Visible = parsed_data.developer_settings.Is_Hovering_Block_Visible
	Settings_Data.Is_Current_Active_Block_Visible = parsed_data.developer_settings.Is_Current_Active_Block_Visible
	Settings_Data.Is_Current_Active_Event_Visible = parsed_data.developer_settings.Is_Current_Active_Event_Visible
	Settings_Data.Is_Current_Time_Info_Visible = parsed_data.developer_settings.Is_Current_Time_Info_Visible
	Settings_Data.Is_Player_Current_Room_Info_Visible = parsed_data.developer_settings.Is_Player_Current_Room_Info_Visible

func on_delete_settings_data():
	if FileAccess.file_exists(Settings_File_Path) == true:
		print_debug("Deleting file %s" % [Settings_File_Path])
		DirAccess.remove_absolute(Settings_File_Path)
		return
	else:
		print_debug("File %s does not exist." % [Settings_File_Path])
		return


const Game_File_Path: String = "res://game.json"
var Game_Dictionary: Dictionary = {}

func verify_game_file_directory(path: String):
	if FileAccess.file_exists(path):
		Game_Data = GameData.new()
		SignalManager.load_game_data.emit()
		return
	else:
		Global.Game_Data = GameData.new()
		var file = FileAccess.open(path, FileAccess.WRITE)

		var default_data = {
			"time": {
				"Time_String" = Game_Data.Time_String,
				"Time_Hour" = Game_Data.Time_Hour,
				"Time_Minute" = Game_Data.Time_Minute,
			},
			"monster": {
				"Is_Monster_Active" = Game_Data.Is_Monster_Active,
				"Monster_Current_Room" = Game_Data.Monster_Current_Room,
				"Monster_Current_Stage" = Game_Data.Monster_Current_Stage,
				"Monster_Room_Number" = Game_Data.Monster_Room_Number,
			},
			"player": {
				"Current_Active_Block" = Game_Data.Current_Active_Block,
				"Current_Block_Name" = Game_Data.Current_Block_Name,
				"Current_Event" = Game_Data.Current_Event,
				"Current_Room" = Game_Data.Current_Room,
				"Current_Room_Number" = Game_Data.Current_Room_Number
			}
		}

		Game_Dictionary.merge(default_data, true)
		var json_string = JSON.stringify(Game_Dictionary, "\t")
		file.store_string(json_string)
		file.close()
		return

func save_time_game_data():
	print_debug("Saving time data")

	var data: Dictionary = {
		"time": {
			"Time_String" = Game_Data.Time_String,
			"Time_Hour" = Game_Data.Time_Hour,
			"Time_Minute" = Game_Data.Time_Minute,
		}
	}
	Game_Dictionary.merge(data, true)

func save_monster_game_data():
	print_debug("Saving monster data")

	var data: Dictionary = {
		"monster": {
			"Is_Monster_Active" = Game_Data.Is_Monster_Active,
			"Monster_Current_Room" = Game_Data.Monster_Current_Room,
			"Monster_Current_Stage" = Game_Data.Monster_Current_Stage,
			"Monster_Room_Number" = Game_Data.Monster_Room_Number,
		}
	}
	Game_Dictionary.merge(data, true)

func save_player_game_data():
	print_debug("Saving player data")

	var data: Dictionary = {
		"player": {
			"Current_Active_Block" = Game_Data.Current_Active_Block,
			"Current_Block_Name" = Game_Data.Current_Block_Name,
			"Current_Event" = Game_Data.Current_Event,
			"Current_Room" = Game_Data.Current_Room,
			"Current_Room_Number" = Game_Data.Current_Room_Number
		}
	}
	Game_Dictionary.merge(data, true)

func on_save_game_data():
	print_debug("Saving game data")
	var file = FileAccess.open(Game_File_Path, FileAccess.WRITE)
	if file == null:
		push_warning(str(FileAccess.get_open_error()))
		return

	save_monster_game_data()
	save_player_game_data()
	save_time_game_data()

	var json_string = JSON.stringify(Game_Dictionary, "\t")
	file.store_string(json_string)
	file.close()
	return

func search_for_block(node: Node, identifier: String):
	for child in node.get_children(true):
		if child is Block and child.name == identifier:
			print_debug(child)
			return child
		elif child is Block and child.name != identifier:
			pass
		search_for_block(child, identifier)

func search_for_room(node: Node, identifier: int):
	for child in node.get_children(true):
		if child is RoomBlock and child.RoomNumber == identifier:
			print_debug(child)
			Game_Data.Monster_Current_Room = child
		elif child is RoomBlock and child.RoomNumber != identifier:
			pass
		search_for_room(child, identifier)

func load_game_data(parsed_data: Dictionary):
	Game_Data.Current_Active_Block = search_for_block(Global.Loaded_Game_World, parsed_data.player.Current_Active_Block)
	Game_Data.Current_Block_Name = parsed_data.player.Current_Block_Name
	Game_Data.Current_Event = parsed_data.player.Current_Event
	Game_Data.Current_Room = search_for_block(Global.Loaded_Game_World, parsed_data.player.Current_Room)
	Game_Data.Current_Room_Number = parsed_data.player.Current_Room_Number

	Game_Data.Is_Monster_Active = parsed_data.monster.Is_Monster_Active
	search_for_room(Global.Loaded_Game_World, parsed_data.monster.Monster_Room_Number)
	Game_Data.Monster_Current_Stage = parsed_data.monster.Monster_Current_Stage
	Game_Data.Monster_Room_Number = parsed_data.monster.Monster_Room_Number

	Game_Data.Time_String = parsed_data.time.Time_String
	Game_Data.Time_Hour = parsed_data.time.Time_Hour
	Game_Data.Time_Minute = parsed_data.time.Time_Minute

func load_data(path: String, type: String):
	print_debug("Loading %s-data from %s." % [type, path])

	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file == null:
			push_warning(str(FileAccess.get_open_error()))
			return

		var raw_data = file.get_as_text()
		file.close()

		var parsed_data = JSON.parse_string(raw_data)
		if parsed_data == null:
			push_error("Cannot parse %s as a json-string: %s" % [path, raw_data])
			return

		if type == "settings":
			load_settings_data(parsed_data)
			return
		elif type == "game":
			load_game_data(parsed_data)
			return

func on_delete_game_data():
	if FileAccess.file_exists(Game_File_Path) == true:
		print_debug("Deleting file %s" % [Game_File_Path])
		DirAccess.remove_absolute(Game_File_Path)
		return
	else:
		print_debug("File %s does not exist." % [Game_File_Path])
		return

func manage_signals():
	SignalManager.load_settings_data.connect(Callable(load_data).bind(Settings_File_Path, "settings"))
	SignalManager.save_settings_data.connect(on_save_settings_data)
	SignalManager.delete_settings_data.connect(on_delete_settings_data)

	SignalManager.load_game_data.connect(Callable(load_data).bind(Game_File_Path, "game"))
	SignalManager.save_game_data.connect(on_save_game_data)
	SignalManager.delete_game_data.connect(on_delete_game_data)

func _ready():
	Settings_Data = SettingsData.new()
	Game_Data = GameData.new()

	manage_signals()
	verify_settings_file_directory(Settings_File_Path)
	set_window_resolution(Settings_Data.Selected_Resolution_Index)

func _process(_delta):
	manage_mouse_cursor()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			Is_Window_Focused = false
		NOTIFICATION_WM_MOUSE_ENTER:
			Is_Window_Focused = true
