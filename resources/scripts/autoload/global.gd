extends Node

var Screen_Centre: Vector2

# Sound
var Master_Volume_Setting: float
var Music_Volume_Setting: float
var SFX_Volume_Setting: float
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

## Dev Utilities
var Is_Monster_Info_Visible: bool
var Is_Fps_Counter_Visible: bool
var Is_Player_Info_Visible: bool
var Is_Hovering_Block_Visible: bool
var Is_Current_Active_Block_Visible: bool
var Is_Current_Active_Event_Visible: bool
var Is_Current_Time_Info_Visible: bool
var Is_Player_Current_Room_Info_Visible: bool

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

func load_dev_settings(file):
	print_debug("Loading dev settings.")
	Is_Fps_Counter_Visible = file.get_var(Is_Fps_Counter_Visible)
	Is_Player_Info_Visible = file.get_var(Is_Player_Info_Visible)
	Is_Hovering_Block_Visible = file.get_var(Is_Hovering_Block_Visible)
	Is_Current_Active_Block_Visible = file.get_var(Is_Current_Active_Block_Visible)
	Is_Current_Active_Event_Visible = file.get_var(Is_Current_Active_Event_Visible)
	Is_Current_Time_Info_Visible = file.get_var(Is_Current_Time_Info_Visible)
	Is_Player_Current_Room_Info_Visible = file.get_var(Is_Player_Current_Room_Info_Visible)
	Is_Monster_Info_Visible = file.get_var(Is_Monster_Info_Visible)

func save_dev_settings(file):
	print_debug("Saving dev settings.")
	file.store_var(Is_Fps_Counter_Visible)
	file.store_var(Is_Player_Info_Visible)
	file.store_var(Is_Hovering_Block_Visible)
	file.store_var(Is_Current_Active_Block_Visible)
	file.store_var(Is_Current_Active_Event_Visible)
	file.store_var(Is_Current_Time_Info_Visible)
	file.store_var(Is_Player_Current_Room_Info_Visible)
	file.store_var(Is_Monster_Info_Visible)

func set_default_dev_settings():
	print_debug("Setting default dev settings.")
	Is_Monster_Info_Visible = true
	Is_Fps_Counter_Visible = true
	Is_Player_Info_Visible = false
	Is_Hovering_Block_Visible = false
	Is_Current_Active_Block_Visible = false
	Is_Current_Active_Event_Visible = false
	Is_Current_Time_Info_Visible = true
	Is_Player_Current_Room_Info_Visible = true

func set_default_sound_settings():
	print_debug("Setting default sound settings.")
	Master_Volume_Setting = 0.0
	Music_Volume_Setting = -30.0
	SFX_Volume_Setting = 0.0

func save_sound_settings(file):
	print_debug("Saving sound settings:")
	file.store_var(Master_Volume_Setting)
	print_debug("Master volume:" + str(Master_Volume_Setting))
	file.store_var(Music_Volume_Setting)
	print_debug("Music volume:" + str(Music_Volume_Setting))
	file.store_var(SFX_Volume_Setting)
	print_debug("SFX volume:" + str(SFX_Volume_Setting))

func load_sound_settings(file):
	print_debug("Loading sound settings.")
	Master_Volume_Setting = file.get_var(Master_Volume_Setting)
	print_debug("Master volume:" + str(file.get_var(Master_Volume_Setting)))
	Music_Volume_Setting = file.get_var(Music_Volume_Setting)
	print_debug("Music volume:" + str(file.get_var(Music_Volume_Setting)))
	print_debug(SFX_Volume_Setting)
	SFX_Volume_Setting = file.get_var(SFX_Volume_Setting)
	print_debug("SFX volume:" + str(file.get_var(SFX_Volume_Setting)))

const settings_file_path: String = "res://settings.json"

func load_settings():
	if FileAccess.file_exists(settings_file_path):
		var file = FileAccess.open(settings_file_path, FileAccess.READ)
		load_sound_settings(file)
		load_dev_settings(file)
		file.close()
	else:
		print_debug(str(FileAccess.get_open_error()) + "No settings data found. Using defaults.")
		set_default_sound_settings()
		set_default_dev_settings()

func save_settings():
	var file = FileAccess.open(settings_file_path, FileAccess.WRITE)
	save_dev_settings(file)
	save_sound_settings(file)
	file.close()

func _ready():
	load_settings()
	SignalManager.save_settings.connect(save_settings)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			Is_Window_Focused = false
		NOTIFICATION_WM_MOUSE_ENTER:
			Is_Window_Focused = true
