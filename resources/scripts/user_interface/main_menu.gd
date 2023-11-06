extends CanvasLayer

@onready var NewGameMargin = %NewGameMargin
@onready var ContinueMargin = %ContinueMargin

func _on_options_button_up():
	self.set_visible(false)
	SignalManager.show_options_menu.emit()

func _on_quit_button_up():
	get_tree().quit()

func _ready():
	Global.Loaded_Main_Menu = self
	SignalManager.show_main_menu.connect(Callable(self.set_visible).bind(true))
	SignalManager.game_world_loaded.connect(Callable(self.queue_free))
	SignalManager.main_menu_loaded.emit()
	SignalManager.play_track.emit()
	ContinueMargin.set_visible(false)

func _on_github_button_button_up():
	OS.shell_open("https://github.com/ciarafair/bluerock_avenue")

func _on_new_game_button_up():
	SignalManager.new_game.emit()

func _on_continue_button_up():
	SignalManager.load_game_world.emit()
	Global.verify_game_file_directory(Global.Game_File_Path)

func _process(_delta):
	if FileAccess.file_exists(Global.Game_File_Path) == true:
		ContinueMargin.set_visible(true)

func _on_tree_exiting():
	Global.Loaded_Main_Menu = null
