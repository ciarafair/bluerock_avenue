extends Node

var Screen_Centre: Vector2
var Settings_Data: SettingsData = SettingsData.new()


# Sound
var Current_Track: String = ""

var Current_Window_Size: Vector2i = Vector2i(1920,1080)
var Selected_Resolution_Index: int

var Time_String: String
var Time_Hour: int
var Time_Minute: int
var Is_Window_Focused := true

# Bools
## Misc
var Is_Flashlight_On: bool = false
var Is_Game_Active: bool = false
var Is_Pause_Menu_Open: bool = false
var Is_Able_To_Turn: bool = false
var Is_Music_Playing: bool = false

## Monster
var Is_Monster_Active: bool = false
var Is_Window_Being_Opened: bool = false
var Is_Window_Being_Closed: bool = false
var Is_Window_Open: bool = false
var Is_Door_Opened: bool = false

## Movement Control
var Is_Clickable: bool = false
var Is_In_Animation: bool = false
var Is_Timed_Out: bool = false

## Cursor Icon Control
var Is_Hovering_Over_Bottom_Movement_Panel: bool = false
var Is_Hovering_Over_Left_Movement_Panel: bool = false
var Is_Hovering_Over_Right_Movement_Panel: bool = false

var Current_Active_Block: Block = null
var Current_Event: String = ""
var Current_Room: Block = null
var Monster_Current_Room: RoomBlock
var Monster_Current_Stage: int = 0

# Make Loaded Nodes Accessible
var Loaded_Player: Node3D = null
var Loaded_Game_World: Node3D = null

# Raycasting
var MousePosition2D: Vector2 = Vector2(0,0)
var SpaceState: PhysicsDirectSpaceState3D
var RAYCAST_COLLISION_OBJECT
var Hovering_Block: Block
var FLASHLIGHT_RAY_ARRAY: Array = []

func on_tween_finished():
	#print_debug("Tween completed")
	Global.Is_In_Animation = false

const Settings_File_Path: String = "res://settings.json"
var Settings_Dictionary: Dictionary = {}

func verify_save_directory(path: String):
	if FileAccess.file_exists(path):
		load_data(Settings_File_Path)
		return
	else:
		Settings_Data = SettingsData.new()
		var file = FileAccess.open(path, FileAccess.WRITE)

		var default_data = {
			"dev_settings": {
				"Is_Current_Active_Block_Visible": false,
				"Is_Current_Active_Event_Visible": false,
				"Is_Current_Time_Info_Visible": false,
				"Is_Fps_Counter_Visible": false,
				"Is_Hovering_Block_Visible": false,
				"Is_Monster_Info_Visible": false,
				"Is_Player_Current_Room_Info_Visible": false,
				"Is_Player_Info_Visible": false
			},
			"sound_settings": {
				"Master_Volume_Setting": 0,
				"Music_Volume_Setting": -30,
				"SFX_Volume_Setting": 0
			}
		}

		Settings_Dictionary.merge(default_data, true)
		var json_string = JSON.stringify(Settings_Dictionary, "\t")
		file.store_string(json_string)
		file.close()
		return

func save_dev_settings():
	print_debug("Saving dev settings.")

	var data = {
		"dev_settings":{
			"Is_Fps_Counter_Visible" = Settings_Data.Is_Fps_Counter_Visible,
			"Is_Player_Info_Visible" = Settings_Data.Is_Player_Info_Visible,
			"Is_Hovering_Block_Visible" = Settings_Data.Is_Hovering_Block_Visible,
			"Is_Current_Active_Block_Visible" = Settings_Data.Is_Current_Active_Block_Visible,
			"Is_Current_Active_Event_Visible" = Settings_Data.Is_Current_Active_Event_Visible,
			"Is_Current_Time_Info_Visible" = Settings_Data.Is_Current_Time_Info_Visible,
			"Is_Player_Current_Room_Info_Visible" = Settings_Data.Is_Player_Current_Room_Info_Visible,
			"Is_Monster_Info_Visible" = Settings_Data.Is_Monster_Info_Visible
		}
	}

	Settings_Dictionary.merge(data, true)

func save_sound_settings():
	print_debug("Saving sound settings")

	var data: Dictionary = {
		"sound_settings":{
			"Master_Volume_Setting" = Settings_Data.Master_Volume_Setting,
			"Music_Volume_Setting" = Settings_Data.Music_Volume_Setting,
			"SFX_Volume_Setting" = Settings_Data.SFX_Volume_Setting
		}
	}

	Settings_Dictionary.merge(data, true)

func save_settings():
	var file = FileAccess.open(Settings_File_Path, FileAccess.WRITE)
	if file == null:
		push_warning(str(FileAccess.get_open_error()))
		return

	save_sound_settings()
	save_dev_settings()

	var json_string = JSON.stringify(Settings_Dictionary, "\t")
	file.store_string(json_string)
	file.close()
	return

func load_data(path: String):
	print_debug("Loading data from %s." % [path])

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

		Settings_Data.Master_Volume_Setting = parsed_data.sound_settings.Master_Volume_Setting
		Settings_Data.Music_Volume_Setting = parsed_data.sound_settings.Music_Volume_Setting
		Settings_Data.SFX_Volume_Setting = parsed_data.sound_settings.SFX_Volume_Setting

		Settings_Data.Is_Monster_Info_Visible = parsed_data.dev_settings.Is_Monster_Info_Visible
		Settings_Data.Is_Fps_Counter_Visible = parsed_data.dev_settings.Is_Fps_Counter_Visible
		Settings_Data.Is_Player_Info_Visible = parsed_data.dev_settings.Is_Player_Info_Visible
		Settings_Data.Is_Hovering_Block_Visible = parsed_data.dev_settings.Is_Hovering_Block_Visible
		Settings_Data.Is_Current_Active_Block_Visible = parsed_data.dev_settings.Is_Current_Active_Block_Visible
		Settings_Data.Is_Current_Active_Event_Visible = parsed_data.dev_settings.Is_Current_Active_Event_Visible
		Settings_Data.Is_Current_Time_Info_Visible = parsed_data.dev_settings.Is_Current_Time_Info_Visible
		Settings_Data.Is_Player_Current_Room_Info_Visible = parsed_data.dev_settings.Is_Player_Current_Room_Info_Visible

		return

	else:
		push_error("Cannot open non-existent file at %s!" % [path])
		return

func _ready():
	verify_save_directory(Settings_File_Path)
	SignalManager.save_settings.connect(save_settings)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			Is_Window_Focused = false
		NOTIFICATION_WM_MOUSE_ENTER:
			Is_Window_Focused = true
