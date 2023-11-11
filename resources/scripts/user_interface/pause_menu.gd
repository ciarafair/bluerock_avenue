extends CanvasLayer

var IsOptionsMenuOpen: bool = false

func _on_resume_game_button_up():
	#print_debug("Resume button was pressed.")
	Global.Is_Pause_Menu_Open = !Global.Is_Pause_Menu_Open
	get_tree().paused = false
	SignalManager.hide_pause_menu.emit()

func _on_options_button_up():
	#print_debug("Options button was pressed.")
	set_visible(false)
	SignalManager.load_settings_data.emit()
	SignalManager.show_options_menu.emit()
	IsOptionsMenuOpen = true

func _on_quit_button_up():
	#print_debug("Quit button was pressed.")
	Global.Is_Pause_Menu_Open = false
	SignalManager.save_game_data.emit()
	SignalManager.load_main_menu.emit()
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
	check_pause_menu()

func manage_signals():
	SignalManager.main_menu_loaded.connect(Callable(self.queue_free))
	SignalManager.show_pause_menu.connect(Callable(self.set_visible).bind(true))
	SignalManager.hide_pause_menu.connect(Callable(self.set_visible).bind(false))

func _ready():
	self.set_visible(false)
	manage_signals()
	Global.Loaded_Pause_Menu = self
	SignalManager.pause_menu_loaded.emit()
