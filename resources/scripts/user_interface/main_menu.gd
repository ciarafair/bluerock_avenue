extends CanvasLayer

func _on_start_game_button_up():
	SignalManager.load_game_world.emit()

func _on_options_button_up():
	SignalManager.load_options_menu.emit()

func _on_quit_button_up():
	get_tree().quit()

func _on_tree_entered():
	Global.GameState = "main_menu"
	SignalManager.main_menu_loaded.emit()
	SignalManager.play_track.emit()

func _on_tree_exiting():
	Global.GameState = ""
