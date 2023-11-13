extends Node

const MajorBuildNum: int = 1
const MinorBuildNum: int = 0
const RevisionNum: int = 1

var Settings_Data_Instance: SettingsData
var Game_Data_Instance: GameData

# Meta Data - Stays in this script as it does not need to be saved
const CharacterReadRate: float = 0.025

var Object_Loader: Node = null

var PlayerInstance: Node3D = null
var MonsterInstance: Node3D = null
var PauseMenuInstance: CanvasLayer = null
var MovementInterfaceInstance: CanvasLayer = null
var GameOverScreenInstance: CanvasLayer = null
var TaskListInstance: CanvasLayer = null
var DialogueBoxInstance: CanvasLayer = null

var Loaded_Game_World: Node3D = null
var Loaded_User_Interface: Control = null
var Loaded_Options_Menu: CanvasLayer = null
var Loaded_Main_Menu: CanvasLayer = null
var Loaded_Pause_Menu: CanvasLayer = null

var Loaded_Overlay_Effect: CanvasLayer = null

var Is_Window_Focused: bool = true
var Current_Track: String = ""

var Is_Door_Open: bool = false
var Is_Music_Playing: bool = false
var Is_Game_Active: bool = false
var Is_Pause_Menu_Open: bool = false
var Is_Clickable: bool = false
var Is_In_Animation: bool = false
var Is_Timed_Out: bool = false
var Is_Window_Being_Opened: bool = false
var Is_Window_Open: bool = false
var Is_Window_Being_Closed: bool = false
var Is_Able_To_Turn: bool = false

var Current_Movement_Panel: Panel = null
var ScreenCentre: Vector2i
var SpaceState: PhysicsDirectSpaceState3D
var RAYCAST_COLLISION_OBJECT
var Hovering_Block: Block
var FLASHLIGHT_RAY_ARRAY: Array = []

func on_tween_finished():
	#print_debug("Tween completed")
	Global.Is_In_Animation = false
	SignalManager.animation_finished.emit()

var CurrentMouseState: MouseState
var MousePosition2D: Vector2

enum MouseState {
	MOVEMENT = 1,
	DIALOGUE = 2,
	ROTATION = 3
}

enum task {
	TURN_OFF_TV = 1,
	EXPLORE = 2,
	SURVIVE = 3
}

@onready var EyeCursor = preload("res://resources/textures/mouse_cursors/eye.png")
@onready var DialogueCursor = preload("res://resources/textures/mouse_cursors/speech_bubble.png")
@onready var DownArrowCursor = preload("res://resources/textures/mouse_cursors/down_arrow.png")
@onready var LeftArrowCursor = preload("res://resources/textures/mouse_cursors/left_arrow.png")
@onready var RightArrowCursor = preload("res://resources/textures/mouse_cursors/right_arrow.png")

func manage_mouse_cursor():
	if Is_Game_Active == true:
		if CurrentMouseState == MouseState.MOVEMENT:
			if Hovering_Block != null:
				Input.set_custom_mouse_cursor(EyeCursor)
				return
			else:
				Input.set_custom_mouse_cursor(null)
				return

		elif CurrentMouseState == MouseState.DIALOGUE:
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

		elif CurrentMouseState == MouseState.ROTATION:
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

func set_mouse_state(next: MouseState):
	CurrentMouseState = next
	match CurrentMouseState:
		MouseState.MOVEMENT:
			#print_debug("Changing mouse state to %s" %[new_state])
			pass

		MouseState.DIALOGUE:
			#print_debug("Changing mouse state to %s" %[new_state])
			pass

		MouseState.ROTATION:
			#print_debug("Changing mouse state to %s" %[new_state])
			pass

var Settings_Dictionary: Dictionary = {}
func verify_settings_file_directory():
	if FileAccess.file_exists(Path.SettingsJSONFilePath):
		SignalManager.load_settings_data.emit()
		return
	else:
		Global.Settings_Data_Instance = SettingsData.new()
		var file = FileAccess.open(Path.SettingsJSONFilePath, FileAccess.WRITE)

		var default_data = {
			"developer_settings": {
				"Is_Current_Active_Block_Visible": Settings_Data_Instance.Is_Current_Active_Block_Visible,
				"Is_Current_Active_Event_Visible": Settings_Data_Instance.Is_Current_Active_Event_Visible,
				"Is_Current_Time_Info_Visible": Settings_Data_Instance.Is_Current_Time_Info_Visible,
				"Is_Fps_Counter_Visible": Settings_Data_Instance.Is_Fps_Counter_Visible,
				"Is_Hovering_Block_Visible": Settings_Data_Instance.Is_Hovering_Block_Visible,
				"Is_Monster_Info_Visible": Settings_Data_Instance.Is_Monster_Info_Visible,
				"Is_Player_Current_Room_Info_Visible": Settings_Data_Instance.Is_Player_Current_Room_Info_Visible,
				"Is_Player_Info_Visible": Settings_Data_Instance.Is_Player_Info_Visible,
				"Is_Monster_Active": Game_Data_Instance.Is_Monster_Active
			},
			"volume_settings": {
				"Master_Volume_Setting": Settings_Data_Instance.Master_Volume_Setting,
				"Music_Volume_Setting": Settings_Data_Instance.Music_Volume_Setting,
				"SFX_Volume_Setting": Settings_Data_Instance.SFX_Volume_Setting
			},
			"general_settings": {
				"Mouse_Sensitivity": Settings_Data_Instance.Mouse_Sensitivity,
				"Is_Overlay_Effect_Enabled": Settings_Data_Instance.Is_Overlay_Effect_Enabled,
				"Selected_Resolution_Index": Settings_Data_Instance.Selected_Resolution_Index
			}
		}

		Settings_Dictionary.merge(default_data, true)
		var json_string = JSON.stringify(Settings_Dictionary, "\t")
		file.store_string(json_string)
		file.close()
		return

func save_developer_settings():
	#print_debug("Saving developer settings.")

	var data = {
		"developer_settings":{
			"Is_Fps_Counter_Visible" = Settings_Data_Instance.Is_Fps_Counter_Visible,
			"Is_Player_Info_Visible" = Settings_Data_Instance.Is_Player_Info_Visible,
			"Is_Hovering_Block_Visible" = Settings_Data_Instance.Is_Hovering_Block_Visible,
			"Is_Current_Active_Block_Visible" = Settings_Data_Instance.Is_Current_Active_Block_Visible,
			"Is_Current_Active_Event_Visible" = Settings_Data_Instance.Is_Current_Active_Event_Visible,
			"Is_Current_Time_Info_Visible" = Settings_Data_Instance.Is_Current_Time_Info_Visible,
			"Is_Player_Current_Room_Info_Visible" = Settings_Data_Instance.Is_Player_Current_Room_Info_Visible,
			"Is_Monster_Info_Visible" = Settings_Data_Instance.Is_Monster_Info_Visible,
			"Is_Monster_Active" = Game_Data_Instance.Is_Monster_Active
		}
	}
	Settings_Dictionary.merge(data, true)

func save_volume_settings():
	#print_debug("Saving volume settings")

	var data: Dictionary = {
		"volume_settings":{
			"Master_Volume_Setting" = Settings_Data_Instance.Master_Volume_Setting,
			"Music_Volume_Setting" = Settings_Data_Instance.Music_Volume_Setting,
			"SFX_Volume_Setting" = Settings_Data_Instance.SFX_Volume_Setting
		}
	}
	Settings_Dictionary.merge(data, true)

func save_general_settings():
	#print_debug("Saving general settings")

	var data: Dictionary = {
		"general_settings": {
			"Mouse_Sensitivity": Settings_Data_Instance.Mouse_Sensitivity,
			"Is_Overlay_Effect_Enabled": Settings_Data_Instance.Is_Overlay_Effect_Enabled,
			"Selected_Resolution_Index": Settings_Data_Instance.Selected_Resolution_Index
		}
	}
	Settings_Dictionary.merge(data, true)

func on_save_settings_data():
	print_debug("Saving settings data")
	var file = FileAccess.open(Path.SettingsJSONFilePath, FileAccess.WRITE)
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
		Global.Settings_Data_Instance.Current_Window_Size = Vector2i(1920,1080)
		Global.Settings_Data_Instance.Selected_Resolution_Index = 0
		get_window().size = Global.Settings_Data_Instance.Current_Window_Size

	if index == 1:
		Global.Settings_Data_Instance.Current_Window_Size = Vector2i(1600,900)
		Global.Settings_Data_Instance.Selected_Resolution_Index = 1
		get_window().size = Global.Settings_Data_Instance.Current_Window_Size

	if index == 2:
		Global.Settings_Data_Instance.Current_Window_Size = Vector2i(1280,720)
		Global.Settings_Data_Instance.Selected_Resolution_Index = 2
		get_window().size = Global.Settings_Data_Instance.Current_Window_Size

func load_settings_data(parsed_data: Dictionary):
	Settings_Data_Instance.Mouse_Sensitivity = parsed_data.general_settings.Mouse_Sensitivity
	Settings_Data_Instance.Is_Overlay_Effect_Enabled = parsed_data.general_settings.Is_Overlay_Effect_Enabled
	Settings_Data_Instance.Selected_Resolution_Index = parsed_data.general_settings.Selected_Resolution_Index

	Settings_Data_Instance.Master_Volume_Setting = parsed_data.volume_settings.Master_Volume_Setting
	Settings_Data_Instance.Music_Volume_Setting = parsed_data.volume_settings.Music_Volume_Setting
	Settings_Data_Instance.SFX_Volume_Setting = parsed_data.volume_settings.SFX_Volume_Setting

	Settings_Data_Instance.Is_Monster_Info_Visible = parsed_data.developer_settings.Is_Monster_Info_Visible
	Settings_Data_Instance.Is_Fps_Counter_Visible = parsed_data.developer_settings.Is_Fps_Counter_Visible
	Settings_Data_Instance.Is_Player_Info_Visible = parsed_data.developer_settings.Is_Player_Info_Visible
	Settings_Data_Instance.Is_Hovering_Block_Visible = parsed_data.developer_settings.Is_Hovering_Block_Visible
	Settings_Data_Instance.Is_Current_Active_Block_Visible = parsed_data.developer_settings.Is_Current_Active_Block_Visible
	Settings_Data_Instance.Is_Current_Active_Event_Visible = parsed_data.developer_settings.Is_Current_Active_Event_Visible
	Settings_Data_Instance.Is_Current_Time_Info_Visible = parsed_data.developer_settings.Is_Current_Time_Info_Visible
	Settings_Data_Instance.Is_Player_Current_Room_Info_Visible = parsed_data.developer_settings.Is_Player_Current_Room_Info_Visible

func on_delete_settings_data():
	if FileAccess.file_exists(Path.SettingsJSONFilePath) == true:
		print_debug("Deleting file %s" % [Path.SettingsJSONFilePath])
		DirAccess.remove_absolute(Path.SettingsJSONFilePath)
		return
	else:
		print_debug("File %s does not exist." % [Path.SettingsJSONFilePath])
		return


var Game_Dictionary: Dictionary = {}

func verify_game_file_directory():
	if FileAccess.file_exists(Path.GameJSONFilePath):
		Game_Data_Instance = GameData.new()
		SignalManager.load_game_data.emit()
		return
	else:
		Global.Game_Data_Instance = GameData.new()
		var file = FileAccess.open(Path.GameJSONFilePath, FileAccess.WRITE)

		var default_data = {
			"time": {
				"Time_String" = Game_Data_Instance.Time_String,
				"Time_Hour" = Game_Data_Instance.Time_Hour,
				"Time_Minute" = Game_Data_Instance.Time_Minute,
			},
			"monster": {
				"Is_Monster_Active" = Game_Data_Instance.Is_Monster_Active,
				"Monster_Current_Room" = Game_Data_Instance.Monster_Current_Room,
				"Monster_Current_Stage" = Game_Data_Instance.Monster_Current_Stage,
				"Monster_Room_Number" = Game_Data_Instance.Monster_Room_Number,
			},
			"player": {
				"XRotation" = 0,
				"YRotation" = 0,
				"ZRotation" = 0,
				"XPosition" = 0,
				"YPosition" = 1.75,
				"ZPosition" = 0,
				"Current_Active_Block" = Game_Data_Instance.Current_Active_Block,
				"Current_Block_Name" = Game_Data_Instance.Current_Block_Name,
				"Current_Event" = Game_Data_Instance.Current_Event,
				"Current_Room" = Game_Data_Instance.Current_Room,
				"Current_Room_Number" = Game_Data_Instance.Current_Room_Number
			},
			"world": {
				"Current_Task" = Game_Data_Instance.Current_Task,
				"Television_State" = Game_Data_Instance.Television_State
			}
		}

		Game_Dictionary.merge(default_data, true)
		var json_string = JSON.stringify(Game_Dictionary, "\t")
		file.store_string(json_string)
		file.close()
		return

func save_time_game_data():
	#print_debug("Saving time data")

	var data: Dictionary = {
		"time": {
			"Time_String" = Game_Data_Instance.Time_String,
			"Time_Hour" = Game_Data_Instance.Time_Hour,
			"Time_Minute" = Game_Data_Instance.Time_Minute,
		}
	}
	Game_Dictionary.merge(data, true)

func save_monster_game_data():
	#print_debug("Saving monster data")

	var data: Dictionary = {
		"monster": {
			"Is_Monster_Active" = Game_Data_Instance.Is_Monster_Active,
			"Monster_Current_Room" = Game_Data_Instance.Monster_Current_Room,
			"Monster_Current_Stage" = Game_Data_Instance.Monster_Current_Stage,
			"Monster_Room_Number" = Game_Data_Instance.Monster_Room_Number,
		}
	}
	Game_Dictionary.merge(data, true)

func save_player_game_data():
	#print_debug("Saving player data")

	var data: Dictionary = {
		"player": {
			"XRotation" = PlayerInstance.rotation_degrees.x,
			"YRotation" = PlayerInstance.rotation_degrees.y,
			"ZRotation" = PlayerInstance.rotation_degrees.z,

			"XPosition" = PlayerInstance.position.x,
			"YPosition" = PlayerInstance.position.y,
			"ZPosition" = PlayerInstance.position.z,

			"Current_Active_Block" = Game_Data_Instance.Current_Active_Block,
			"Current_Block_Name" = Game_Data_Instance.Current_Block_Name,
			"Current_Event" = Game_Data_Instance.Current_Event,
			"Current_Room" = Game_Data_Instance.Current_Room,
			"Current_Room_Number" = Game_Data_Instance.Current_Room_Number,
			"Is_Flashlight_On" = Game_Data_Instance.Is_Flashlight_On
		}
	}
	Game_Dictionary.merge(data, true)

func save_world_game_data():
	#print_debug("Saving player data")

	var data: Dictionary = {
		"world": {
			"Current_Task" = Game_Data_Instance.Current_Task,
			"Television_State" = Game_Data_Instance.Television_State
		}
	}
	Game_Dictionary.merge(data, true)

func on_save_game_data():
	#print_debug("Saving game data")
	var file = FileAccess.open(Path.GameJSONFilePath, FileAccess.WRITE)
	if file == null:
		push_warning(str(FileAccess.get_open_error()))
		return

	save_monster_game_data()
	save_world_game_data()
	save_player_game_data()
	save_time_game_data()

	var json_string = JSON.stringify(Game_Dictionary, "\t")
	file.store_string(json_string)
	file.close()
	return

func search_for_block(node: Node, identifier: String) -> Block:
	for child in node.get_children(true):
		if child is Block and child.name == identifier:
			print_debug(child)
			return child
		search_for_block(child, identifier)
	return null

func search_for_room(node: Node, identifier: int):
	for child in node.get_children(true):
		if child is RoomBlock and child.RoomNumber == identifier:
			print_debug(child)
			Game_Data_Instance.Monster_Current_Room = child
		elif child is RoomBlock and child.RoomNumber != identifier:
			pass
		search_for_room(child, identifier)

func load_game_data(parsed_data: Dictionary):
	PlayerInstance.rotation_degrees.x = parsed_data.player.XRotation
	PlayerInstance.rotation_degrees.y = parsed_data.player.YRotation
	PlayerInstance.rotation_degrees.z = parsed_data.player.ZRotation

	PlayerInstance.position.x  = parsed_data.player.XPosition
	PlayerInstance.position.y  = parsed_data.player.YPosition
	PlayerInstance.position.z  = parsed_data.player.ZPosition

	if Game_Data_Instance.Current_Active_Block != null:
		Game_Data_Instance.Current_Active_Block = search_for_block(Global.Loaded_Game_World, parsed_data.player.Current_Active_Block)
	Game_Data_Instance.Current_Block_Name = parsed_data.player.Current_Block_Name
	Game_Data_Instance.Current_Event = parsed_data.player.Current_Event
	if Game_Data_Instance.Current_Room != null:
		Game_Data_Instance.Current_Room = search_for_block(Global.Loaded_Game_World, parsed_data.player.Current_Room)
	Game_Data_Instance.Current_Room_Number = parsed_data.player.Current_Room_Number

	Game_Data_Instance.Is_Monster_Active = parsed_data.monster.Is_Monster_Active
	search_for_room(Global.Loaded_Game_World, parsed_data.monster.Monster_Room_Number)
	Game_Data_Instance.Monster_Current_Stage = parsed_data.monster.Monster_Current_Stage
	Game_Data_Instance.Monster_Room_Number = parsed_data.monster.Monster_Room_Number

	Game_Data_Instance.Time_String = parsed_data.time.Time_String
	Game_Data_Instance.Time_Hour = parsed_data.time.Time_Hour
	Game_Data_Instance.Time_Minute = parsed_data.time.Time_Minute

	Game_Data_Instance.Current_Task = parsed_data.world.Current_Task
	Game_Data_Instance.Television_State = parsed_data.world.Television_State

func load_data(path: String, type: String):
	#print_debug("Loading %s-data from %s." % [type, path])

	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file == null:
			push_warning(str(FileAccess.get_open_error()))
			return

		var raw_data = file.get_as_text()
		file.close()

		var parsed_data = JSON.parse_string(raw_data)
		if parsed_data == null:
			printerr("Cannot parse %s as a json-string: %s" % [path, raw_data])
			return

		if type == "settings":
			load_settings_data(parsed_data)
			return
		elif type == "game":
			load_game_data(parsed_data)
			return

func on_delete_game_data():
	if FileAccess.file_exists(Path.GameJSONFilePath) == true:
		#print_debug("Deleting file %s" % [Game_File_Path])
		DirAccess.remove_absolute(Path.GameJSONFilePath)
		return
	else:
		printerr("File %s does not exist and cannot be deleted." % [Path.GameJSONFilePath])
		return

func manage_signals():
	SignalManager.load_settings_data.connect(Callable(load_data).bind(Path.SettingsJSONFilePath, "settings"))
	SignalManager.save_settings_data.connect(on_save_settings_data)
	SignalManager.delete_settings_data.connect(on_delete_settings_data)

	SignalManager.load_game_data.connect(Callable(load_data).bind(Path.GameJSONFilePath, "game"))
	SignalManager.save_game_data.connect(on_save_game_data)
	SignalManager.delete_game_data.connect(on_delete_game_data)

func stringify_json(json_file: JSON) -> Dictionary:
	var path = json_file.resource_path
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning(str(FileAccess.get_open_error()))
		return {}

	var raw_data = file.get_as_text()
	file.close()

	var parsed_data = JSON.parse_string(raw_data)
	if parsed_data == null:
		printerr("Cannot parse %s as a json-string: %s" % [path, raw_data])
		return {}
	return parsed_data

func set_task(next: task):
	Game_Data_Instance.Current_Task = next
	match Game_Data_Instance.Current_Task:
		task.TURN_OFF_TV:
			#print_debug("Changing mouse state to %s" %[new_state])
			pass

		task.EXPLORE:
			#print_debug("Changing mouse state to %s" %[new_state])
			pass

		task.SURVIVE:
			#print_debug("Changing mouse state to %s" %[new_state])
			pass

func task_check(node) -> Dictionary:
	var TaskErrorDialoguePath = preload(Path.TaskErrorDialoguePath)

	if Global.Game_Data_Instance.Current_Task == Global.task.TURN_OFF_TV:
		if node.name == "TVTable":
			return {}
		else:
			return Global.stringify_json(TaskErrorDialoguePath)
	else:
		return {}

func _ready():
	Settings_Data_Instance = SettingsData.new()
	Game_Data_Instance = GameData.new()

	manage_signals()
	verify_settings_file_directory()
	set_window_resolution(Settings_Data_Instance.Selected_Resolution_Index)

func _process(_delta):
	manage_mouse_cursor()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			Is_Window_Focused = false
		NOTIFICATION_WM_MOUSE_ENTER:
			Is_Window_Focused = true
