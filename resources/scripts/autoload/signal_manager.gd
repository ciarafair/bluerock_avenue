extends Node

signal add_overlay_effect
signal remove_overlay_effect

signal scene_loaded
signal toggle_tv
signal animation_finished

# Dialogue box
signal manage_dialogue

# Pause menu
signal show_options_menu
signal hide_pause_menu

# Global
signal load_settings_data
signal save_settings_data
signal load_game_data
signal player_data_loaded
signal game_data_loaded
signal save_game_data
signal delete_game_data
signal delete_settings_data
signal new_game

# Event manager
signal stop_event
signal random_tick
signal game_over

# Monster
signal set_monster_stage
signal monster_found_position
signal set_monster_room
signal monster_found_room
signal reset_monster

# Game World
signal move_to_room
signal enable_other_side_of_door
signal disable_other_side_of_door

# Door Event
signal open_door
signal close_door
signal toggle_door
signal door_toggled

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
signal activate_popup
signal popup_loaded

## Audio
signal load_audio_manager

## User Interface
signal set_task

signal load_main_menu
signal main_menu_loaded
signal show_main_menu

signal load_options_menu
signal options_menu_loaded
signal exit_options_menu

## game_world.gd
signal load_game_world
signal game_world_loaded
signal free_game_world

signal load_intro_animation
signal intro_animation_loaded
signal intro_animation_completed

signal load_dialogue_box
signal dialogue_box_loaded
signal dialogue_close
signal click_dialogue

signal load_pause_menu
signal pause_menu_loaded
signal show_pause_menu

signal load_movement_interface
signal movement_interface_loaded

signal load_game_over_screen
signal game_over_screen_loaded

signal load_task_list
signal task_list_loaded

signal load_player
signal player_loaded

signal load_monster
signal monster_loaded

signal room_loaded

# Player
signal player_camera_listen
signal mouse_movement
signal reset_player_camera
signal turn_180_degrees
signal turn_negative_90_degrees
signal turn_positive_90_degrees
