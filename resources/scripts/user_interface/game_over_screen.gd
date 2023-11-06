extends CanvasLayer

@onready var ScoreLabel = %ScoreLabel

func on_game_over():
	self.set_visible(true)
	SignalManager.delete_game_data.emit()
	get_tree().paused = true
	Global.Is_Game_Active = false

func _ready():
	self.set_visible(false)
	SignalManager.game_over.connect(on_game_over)
	SignalManager.main_menu_loaded.connect(Callable(self.queue_free))

func _on_quit_to_menu_button_up():
	SignalManager.load_main_menu.emit()
	self.queue_free()

func _on_new_game_button_up():
	self.set_visible(false)
	get_tree().paused = false
	Global.Is_Game_Active = true
	Global.Loaded_Game_World.queue_free()
	SignalManager.delete_game_data.emit()
	Global.Game_Data = GameData.new()
	SignalManager.load_game_world.emit()
	Global.verify_game_file_directory(Global.Game_File_Path)
