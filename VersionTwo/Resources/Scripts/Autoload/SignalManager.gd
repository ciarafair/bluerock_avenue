extends Node

signal stop_event

# DoorEvent.gd
signal open_door
signal close_door
signal leave_room
signal enable_other_side_of_door
signal disable_other_side_of_door

# WindowEvent.gd
signal open_window
signal close_window

# MainMenu.gd & AudioManager.gd
signal play_track
signal stop_track

# Block.gd
signal activate_hovering
signal activate_block
signal deactivate_block

# ObjectLoader.gd
signal load_bedroom
signal load_hallway
signal room_loaded

signal load_game_world
signal game_world_loaded

signal load_main_menu
signal main_menu_loaded

signal load_pause_menu
signal pause_menu_loaded

signal load_options_menu
signal options_menu_loaded
signal exit_options_menu

# Player.gd
signal turn_180_degrees
signal turn_negative_90_degrees
signal turn_positive_90_degrees
