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

func _ready():
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	Global.Loaded_Main_Menu = self
	Global.Is_Game_Active = false
	version_number()
	SignalManager.show_main_menu.connect(Callable(self.set_visible).bind(true))
	SignalManager.main_menu_loaded.emit()
	SignalManager.play_track.emit()
	ContinueMargin.set_visible(false)
	return

func _on_github_button_up():
	OS.shell_open("https://github.com/ciarafair/bluerock_avenue")
	return

func _on_discord_button_up():
	OS.shell_open("https://discord.gg/PXXMWCNtWa")
	return

func _on_new_game_button_up():
	self.queue_free()
	SignalManager.stop_track.emit()
	SignalManager.delete_game_data.emit()
	#SignalManager.load_game_world.emit()
	LoadManager.load_scene(Path.GameWorldPath)
	if Global.Loaded_Game_World != null:
		Global.verify_game_file_directory()
		return
	return

func _on_continue_button_up():
	self.queue_free()
	SignalManager.stop_track.emit()
	LoadManager.load_scene(Path.GameWorldPath)
	if Global.Loaded_Game_World != null:
		Global.verify_game_file_directory()
		return
	return

func _process(_delta):
	if FileAccess.file_exists(Path.GameJSONFilePath) == true:
		ContinueMargin.set_visible(true)
		return

func _on_tree_exiting():
	Global.Loaded_Main_Menu = null
	return

@onready var AnimationPlayerInstance = %AnimationPlayer
func _on_credits_button_up():
	AnimationPlayerInstance.play("saved_popup")
	return
