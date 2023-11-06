extends CanvasLayer

@onready var ScoreLabel = %ScoreLabel

func on_game_over():
	self.set_visible(true)
	get_tree().paused = true
	Global.Is_Game_Active = false
	SignalManager.delete_game_data.emit()

func _ready():
	self.set_visible(false)
	SignalManager.game_over.connect(on_game_over)
	SignalManager.main_menu_loaded.connect(Callable(self.queue_free))

func _on_quit_to_menu_button_up():
	SignalManager.load_main_menu.emit()
	self.queue_free()

func _on_new_game_button_up():
	SignalManager.new_game.emit()
	self.queue_free()
