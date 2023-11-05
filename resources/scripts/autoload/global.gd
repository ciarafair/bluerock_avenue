extends Node

var Settings_Data: SettingsData
var Monster_Data: MonsterData
var Game_Data: GameData

# Game Data
var Is_Window_Being_Opened: bool = false
var Is_Window_Open: bool = false
var Is_Door_Opened: bool = false
var Is_Window_Being_Closed: bool = false
var Time_String: String
var Time_Hour: int
var Time_Minute: int

# Meta Data - Stays in this script as it does not need to be saved
var Is_Window_Focused := true
var Current_Track: String = ""
var Mouse_State: int = 1
var Is_Music_Playing: bool = false
var Is_Game_Active: bool = false
var Is_Pause_Menu_Open: bool = false
var Is_Clickable: bool = false
var Is_In_Animation: bool = false
var Loaded_Player: Node3D = null
var Loaded_Game_World: Node3D = null
var Is_Timed_Out: bool = false
var Current_Movement_Panel: Panel = null
var MousePosition2D: Vector2
var CentreOfScreen: Vector2
var SpaceState: PhysicsDirectSpaceState3D
var RAYCAST_COLLISION_OBJECT
var Hovering_Block: Block
var FLASHLIGHT_RAY_ARRAY: Array = []

# Player Data - move to seperate instance
var Is_Flashlight_On: bool = false
var Is_Able_To_Turn: bool = false

var Current_Active_Block: Block = null
var Current_Event: String = ""
var Current_Room: Block = null

func on_tween_finished():
	#print_debug("Tween completed")
	Global.Is_In_Animation = false

@onready var EyeCursor = preload("res://resources/textures/mouse_cursors/eye.png")
@onready var DialogueCursor = preload("res://resources/textures/mouse_cursors/speech_bubble.png")
@onready var DownArrowCursor = preload("res://resources/textures/mouse_cursors/down_arrow.png")
@onready var LeftArrowCursor = preload("res://resources/textures/mouse_cursors/left_arrow.png")
@onready var RightArrowCursor = preload("res://resources/textures/mouse_cursors/right_arrow.png")

func manage_mouse_cursor():
	if MousePosition2D.x > -get_viewport().get_visible_rect().size.x: MousePosition2D.x = get_viewport().get_visible_rect().size.x
	if MousePosition2D.y > -get_viewport().get_visible_rect().size.y: MousePosition2D.y = get_viewport().get_visible_rect().size.y

	if Mouse_State == 1:
		if Hovering_Block != null:
			Input.set_custom_mouse_cursor(EyeCursor)
		else:
			Input.set_custom_mouse_cursor(null)

	elif Mouse_State == 2:
		if Hovering_Block != null:
			if Hovering_Block.BlockDialoguePath == "":
				Input.set_custom_mouse_cursor(null)
			else:
				Input.set_custom_mouse_cursor(DialogueCursor)
		else:
			Input.set_custom_mouse_cursor(null)

	if Is_Game_Active == false:
		Input.set_custom_mouse_cursor(null)

	elif Mouse_State == 3:
		if Current_Movement_Panel != null:
			if Current_Movement_Panel.name == "Bottom":
				Input.set_custom_mouse_cursor(DownArrowCursor)
			elif Current_Movement_Panel.name == "Right":
				Input.set_custom_mouse_cursor(RightArrowCursor)
			elif Current_Movement_Panel.name == "Left":
				Input.set_custom_mouse_cursor(LeftArrowCursor)
		else:
			Input.set_custom_mouse_cursor(null)

func verify_save_directory(path: String):
	if FileAccess.file_exists(path):
		load_data(Settings_File_Path)
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
				"Is_Player_Info_Visible": Settings_Data.Is_Player_Info_Visible
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
			"Is_Monster_Info_Visible" = Settings_Data.Is_Monster_Info_Visible
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

func save_settings():
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

		return

	else:
		push_error("Cannot open non-existent file at %s!" % [path])
		return

const Settings_File_Path: String = "res://settings.json"
var Settings_Dictionary: Dictionary = {}

func set_window_resolution(index):
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


func _ready():
	Settings_Data = SettingsData.new()
	Monster_Data = MonsterData.new()
	Game_Data = GameData.new()

	verify_save_directory(Settings_File_Path)
	set_window_resolution(Settings_Data.Selected_Resolution_Index)
	SignalManager.save_settings.connect(save_settings)

func _process(_delta):
	manage_mouse_cursor()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			Is_Window_Focused = false
		NOTIFICATION_WM_MOUSE_ENTER:
			Is_Window_Focused = true
