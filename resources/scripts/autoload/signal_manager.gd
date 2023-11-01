extends Node

# Event manager
signal stop_event
signal random_tick
signal game_over

## Monster
signal set_monster_position
signal reset_monster
signal find_monster_room

# Game World
signal move_to_room
signal enable_other_side_of_door
signal disable_other_side_of_door

# Door Event
signal open_door
signal close_door

# Window Event
signal open_window
signal close_window

# MainMenu & AudioManager
signal play_track
signal stop_track

# Block
signal activate_hovering
signal activate_block
signal deactivate_block

# Object Loader
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

# Player
signal turn_180_degrees
signal turn_negative_90_degrees
signal turn_positive_90_degrees
