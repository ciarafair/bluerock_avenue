extends CanvasLayer

func _on_resume_game_button_up():
	print_debug("Resume button was pressed.")
	Global.Is_Pause_Menu_Open = !Global.Is_Pause_Menu_Open

func _on_options_button_up():
	print_debug("Options button was pressed.")
	SignalManager.load_options_menu.emit()

func _on_quit_button_up():
	print_debug("Quit button was pressed.")
	SignalManager.load_main_menu.emit()

func _process(_delta):
	if Global.Is_Pause_Menu_Open == true:
		get_tree().paused = true
		self.set_visible(true)

	if Global.Is_Pause_Menu_Open == false:
		get_tree().paused = false
		self.set_visible(false)

func _ready():
	SignalManager.pause_menu_loaded.emit()
