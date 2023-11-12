extends CanvasLayer

@onready var NewGameMargin = %NewGameMargin
@onready var ContinueMargin = %ContinueMargin

func _on_options_button_up():
	self.set_visible(false)
	SignalManager.show_options_menu.emit()

func _on_quit_button_up():
	get_tree().quit()

func _ready():
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	Global.Loaded_Main_Menu = self
	Global.Is_Game_Active = false
	SignalManager.show_main_menu.connect(Callable(self.set_visible).bind(true))
	SignalManager.main_menu_loaded.emit()
	SignalManager.play_track.emit()
	ContinueMargin.set_visible(false)

func _on_github_button_button_up():
	OS.shell_open("https://github.com/ciarafair/bluerock_avenue")

func _on_new_game_button_up():
	self.queue_free()
	SignalManager.stop_track.emit()
	SignalManager.delete_game_data.emit()
	#SignalManager.load_game_world.emit()
	LoadManager.load_scene(Path.GameWorldPath)
	if Global.Loaded_Game_World != null:
		Global.verify_game_file_directory()

func _on_continue_button_up():
	self.queue_free()
	SignalManager.stop_track.emit()
	LoadManager.load_scene(Path.GameWorldPath)
	if Global.Loaded_Game_World != null:
		Global.verify_game_file_directory()

func _process(_delta):
	if FileAccess.file_exists(Path.GameJSONFilePath) == true:
		ContinueMargin.set_visible(true)

func _on_tree_exiting():
	Global.Loaded_Main_Menu = null

func _on_discord_button_button_up():
	pass # Replace with function body.
