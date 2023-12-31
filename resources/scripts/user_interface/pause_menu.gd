extends CanvasLayer

var IsOptionsMenuOpen: bool = false

func _on_resume_game_button_up():
	#print_rich("Resume button was pressed.")
	#Global.stack_info(get_stack())
	Global.Is_Pause_Menu_Open = !Global.Is_Pause_Menu_Open
	get_tree().paused = false
	SignalManager.hide_pause_menu.emit()
	return

func _on_options_button_up():
	#print_rich("Options button was pressed.")
	#Global.stack_info(get_stack())
	set_visible(false)
	SignalManager.load_settings_data.emit()
	SignalManager.show_options_menu.emit()
	IsOptionsMenuOpen = true
	return

func _on_quit_button_up():
	#print_rich("Quit button was pressed.")
	#Global.stack_info(get_stack())
	Global.Is_Pause_Menu_Open = false
	get_tree().paused = false
	Global.CurrentGameState = Global.game_state.MAINMENU
	LoadManager.load_scene(Path.MainMenuPath)
	return

func _on_save_button_up():
	SignalManager.activate_popup.emit("Game-data written.", 1.5)
	SignalManager.save_game_data.emit()
	return

func check_pause_menu():
	if Global.Is_Pause_Menu_Open == true && Global.Loaded_Options_Menu.visible == false:
			if Global.Is_In_Animation == true:
				await SignalManager.animation_finished
			get_tree().paused = true
			Input.set_custom_mouse_cursor(null)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			self.set_visible(true)
			return

	if Global.Is_Pause_Menu_Open == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		self.set_visible(false)
		return
	pass

func _on_tree_exiting():
	Global.Loaded_Main_Menu = null

func _process(_delta):
	if Global.PauseMenuInstance == null:
		SignalManager.pause_menu_loaded.emit()
		Global.PauseMenuInstance = self

	check_pause_menu()

func manage_signals():
	SignalManager.main_menu_loaded.connect(Callable(self.queue_free))
	SignalManager.show_pause_menu.connect(Callable(self.set_visible).bind(true))
	SignalManager.hide_pause_menu.connect(Callable(self.set_visible).bind(false))

func _ready():
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	self.set_visible(false)
	manage_signals()
	Global.Loaded_Pause_Menu = self
	SignalManager.pause_menu_loaded.emit()
