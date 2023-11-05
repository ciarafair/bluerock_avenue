extends CanvasLayer

@onready var NewGameMargin = %NewGameMargin
@onready var ContinueMargin = %ContinueMargin

func _on_options_button_up():
	SignalManager.load_settings_data.emit()
	SignalManager.load_options_menu.emit()

func _on_quit_button_up():
	get_tree().quit()

func _ready():
	SignalManager.main_menu_loaded.emit()
	SignalManager.play_track.emit()
	ContinueMargin.set_visible(false)

func _on_github_button_button_up():
	OS.shell_open("https://github.com/ciarafair/bluerock_avenue")

func _on_new_game_button_up():
	SignalManager.delete_game_data.emit()
	SignalManager.load_game_world.emit()
	Global.verify_game_file_directory(Global.Game_File_Path)

func _on_continue_button_up():
	SignalManager.load_game_world.emit()
	Global.verify_game_file_directory(Global.Game_File_Path)

func _process(_delta):
	if FileAccess.file_exists(Global.Game_File_Path) == true:
		ContinueMargin.set_visible(true)
