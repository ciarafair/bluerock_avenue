extends Node

# Audio
const Audio_Manager_Path: String = "res://resources/scenes/audio_manager.tscn"
const Main_Menu_Track_One: String = "res://resources/audio/opening_screen.mp3"

# User Interface
const Dev_Utilities_Path: String = "res://resources/scenes/user_interface/developer_utilities.tscn"
const Movement_Interface_Path: String = "res://resources/scenes/user_interface/movement_interface.tscn"
const Main_Menu_Path: String = "res://resources/scenes/user_interface/main_menu.tscn"
const Main_Menu_Animation_Path: String = "res://resources/scenes/user_interface/main_menu_background.tscn"
const Pause_Menu_Path: String = "res://resources/scenes/user_interface/pause_menu.tscn"
const Options_Menu_Path: String = "res://resources/scenes/user_interface/options_menu.tscn"
const Game_Over_Screen_Path: String = "res://resources/scenes/user_interface/game_over_screen.tscn"

# Game World
const Game_World_Path: String = "res://resources/scenes/game_world/game_world.tscn"
const Player_Path: String = "res://resources/scenes/game_world/player.tscn"
const Bedroom_Path: String = "res://resources/scenes/game_world/rooms/bedroom.tscn"
const Hallway_Path: String = "res://resources/scenes/game_world/rooms/hallway.tscn"
const Monster_Path: String = "res://resources/scenes/game_world/monster.tscn"

var GameState: String = ""
var Current_Event: String = ""
var Current_Track: String = ""
var Current_Room: Block = null

# Settings
var Master_Volume_Setting: float = 0.0
var Music_Volume_Setting: float = -30.0
var SFX_Volume_Setting: float = 0.0
const Audio_Bus_Layout: String = "res://default_bus_layout.tres"

var Current_Window_Size: Vector2i = Vector2i(1920,1080)
var Selected_Resolution_Index: int

var time_string: String

# Bools
## Misc
var Is_Flashlight_On: bool = false
var Is_Game_Active: bool = false
var Is_Pause_Menu_Open: bool = false
var Is_Able_To_Turn: bool = false
var Is_Music_Playing: bool = false

## Monster
var Is_Window_Being_Opened: bool = false
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
var Is_Fps_Counter_Visible: bool = true
var Is_Player_Info_Visible: bool = true
var Is_Hovering_Block_Visible: bool = true

var Current_Active_Block: Block = null
var Is_Current_Active_Block_Visible: bool = true
var Is_Current_Active_Event_Visible: bool = true
var Is_Current_Time_Info_Visible: bool = true
var Is_Current_Room_Info_Visible: bool = true

# Make Loaded Nodes Accessible
var Loaded_Player: Node3D = null
var Loaded_Game_World: Node3D = null

# Raycasting
var RAYCAST_COLLISION_OBJECT
var Hovering_Block: Block
var FLASHLIGHT_RAY_ARRAY: Array = []

func on_tween_finished():
	Global.Is_In_Animation = false
	#print_debug("Tween completed")

func mouse_position(MOUSE_POSITION_2D, SPACE, COLLISION_MASK, CAMERA, AREA_BOOL, BODY_BOOL):
	if SPACE == null:
		return

	var LENGTH = 20
	var RAY_FROM = CAMERA.project_ray_origin(MOUSE_POSITION_2D)
	var RAY_TO = RAY_FROM + CAMERA.project_ray_normal(MOUSE_POSITION_2D) * LENGTH
	var QUERY = PhysicsRayQueryParameters3D.create(RAY_FROM, RAY_TO)
	QUERY.set_collision_mask(COLLISION_MASK)
	QUERY.exclude = [CAMERA]
	QUERY.collide_with_areas = AREA_BOOL
	QUERY.collide_with_bodies = BODY_BOOL
	var RESULT = SPACE.intersect_ray(QUERY)

	if RESULT.size() > 0:
		return RESULT
