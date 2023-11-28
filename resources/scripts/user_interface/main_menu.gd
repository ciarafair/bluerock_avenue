extends CanvasLayer

@onready var VersionLabel = %Version
@onready var NewGameMargin = %NewGameMargin
@onready var ContinueMargin = %ContinueMargin

func _on_options_button_up():
	self.set_visible(false)
	SignalManager.show_options_menu.emit()
	return

func _on_quit_button_up():
	get_tree().quit()
	return

func version_number():
	var version: String
	version = "Version " + str(Global.MajorBuildNum) + "." + str(Global.MinorBuildNum) + "." + str(Global.RevisionNum)
	VersionLabel.text = version
	return

func manage_signals():
	SignalManager.exit_options_menu.connect(Callable(self.set_visible).bind(true))

func _ready():
	manage_signals()
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	Global.Loaded_Main_Menu = self
	Global.Is_Game_Active = false
	version_number()
	SignalManager.main_menu_loaded.emit()
	SignalManager.play_track.emit(Global.WereMyRemainsEverFoundTrack)
	ContinueMargin.set_visible(false)
	return

func _on_github_button_up():
	OS.shell_open("https://github.com/ciarafair/bluerock_avenue")
	return

func _on_discord_button_up():
	OS.shell_open("https://discord.gg/PXXMWCNtWa")
	return

func _on_new_game_button_up():
	Global.Settings_Data_Instance.Skip_Introduction = false
	SignalManager.stop_track.emit()
	SignalManager.delete_game_data.emit()
	Global.CurrentGameState = Global.game_state.GAME
	LoadManager.load_scene(Path.GameWorldPath)
	await SignalManager.game_world_loaded
	if Global.Loaded_Game_World:
		Global.verify_game_file_directory()
		self.queue_free()
		return
	self.queue_free()
	return

func _on_continue_button_up():
	SignalManager.stop_track.emit()
	Global.load_data(Path.GameJSONFilePath, "game")
	LoadManager.load_scene(Path.GameWorldPath)
	if Global.Loaded_Game_World:
		Global.verify_game_file_directory()
		self.queue_free()
		return
	self.queue_free()
	return

func _process(_delta):
	if FileAccess.file_exists(Path.GameJSONFilePath) == true:
		ContinueMargin.set_visible(true)
		return

func _on_tree_exiting():
	Global.Loaded_Main_Menu = null
	return

func _on_credits_button_up():
	SignalManager.activate_popup.emit("Feature not available.", 1.5)
	return
