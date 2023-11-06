extends Node

signal animation_finished

# Pause menu
signal show_options_menu

# Global
signal load_settings_data
signal save_settings_data
signal load_game_data
signal save_game_data
signal delete_game_data
signal delete_settings_data
signal new_game

# Event manager
signal stop_event
signal random_tick
signal game_over

# Monster
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

# AudioManager
signal play_track
signal stop_track
signal door_open_sound
signal door_close_sound
signal window_open_sound
signal window_close_sound
signal clock_ticking

# Block
signal activate_hovering
signal activate_block
signal deactivate_block

# Object Loader
signal show_main_menu
signal show_pause_menu

signal load_audio_manager
signal load_game_world
signal load_player
signal load_monster
signal free_game_world
signal load_main_menu
signal load_pause_menu

signal game_world_loaded
signal load_options_menu
signal options_menu_loaded
signal pause_menu_loaded
signal main_menu_loaded
signal room_loaded

signal exit_options_menu

# Player
signal player_camera_listen
signal mouse_movement
signal reset_player_camera
signal turn_180_degrees
signal turn_negative_90_degrees
signal turn_positive_90_degrees
