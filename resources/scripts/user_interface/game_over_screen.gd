extends CanvasLayer

func on_game_over():
	self.set_visible(true)
	get_tree().paused = true

func _ready():
	self.set_visible(false)
	SignalManager.game_over.connect(on_game_over)
