extends Node

# Settings
var Master_Volume_Setting: float = 0.0
var Music_Volume_Setting: float = -30.0
var SFX_Volume_Setting: float = 0.0
const Audio_Bus_Layout: String = "res://default_bus_layout.tres"

var Current_Window_Size: Vector2i = Vector2i(1920,1080)
var Selected_Resolution_Index: int

var Time_String: String
var Time_Hour: int
var Time_Minute: int

# Bools
## Misc
var Is_Flashlight_On: bool = false
var Is_Game_Active: bool = false
var Is_Pause_Menu_Open: bool = false
var Is_Able_To_Turn: bool = false
var Is_Music_Playing: bool = false

## Monster
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

var Current_Track: String = ""
var Is_Fps_Counter_Visible: bool = true
var Is_Player_Info_Visible: bool = false
var Is_Hovering_Block_Visible: bool = false
var Current_Active_Block: Block = null
var Is_Current_Active_Block_Visible: bool = false
var Current_Event: String = ""
var Is_Current_Active_Event_Visible: bool = false
var Is_Current_Time_Info_Visible: bool = true
var Current_Room: Block = null
var Is_Player_Current_Room_Info_Visible: bool = true
var Monster_Current_Room: RoomBlock
var Monster_Current_Stage: int = 0
var Is_Monster_Info_Visible: bool = true

# Make Loaded Nodes Accessible
var Loaded_Player: Node3D = null
var Loaded_Game_World: Node3D = null

# Raycasting
var RAYCAST_COLLISION_OBJECT
var Hovering_Block: Block
var FLASHLIGHT_RAY_ARRAY: Array = []

func on_tween_finished():
	#print_debug("Tween completed")
	Global.Is_In_Animation = false
