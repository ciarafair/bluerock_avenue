extends CanvasLayer

var TweenInstance: Tween

@onready var ScoreLabel = %Score
func on_game_over():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.set_visible(true)
	SignalManager.delete_game_data.emit()
	Global.Loaded_Game_World.queue_free()
	set_dialogue()
	Global.Is_Game_Active = false

func _process(_delta):
	if Global.GameOverScreenInstance == null:
		SignalManager.game_over_screen_loaded.emit()
		Global.GameOverScreenInstance = self

var dialogue_text: String = "Your remains were never recovered."
@onready var DialogueLabel = %Dialogue

func set_dialogue():
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(DialogueLabel)
	DialogueLabel.text = str(dialogue_text)

	TweenInstance.pause()
	TweenInstance.tween_property(DialogueLabel, "visible_ratio", 1.0, len(dialogue_text) * Global.CharacterReadRate)
	TweenInstance.play()
	return

func _ready():
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	self.set_visible(false)
	SignalManager.game_over.connect(on_game_over)
	SignalManager.main_menu_loaded.connect(Callable(self.queue_free))
	return

func _on_new_game_button_up():
	SignalManager.stop_track.emit()
	SignalManager.delete_game_data.emit()
	LoadManager.load_scene(Path.GameWorldPath)
	await SignalManager.game_world_loaded
	if Global.Loaded_Game_World:
		Global.verify_game_file_directory()
		self.queue_free()
		return
	push_error("Loaded game world was not found.")
	self.queue_free()
	return

func _on_main_menu_button_up():
	LoadManager.load_scene(Path.MainMenuPath)
	self.queue_free()
	return

func _on_desktop_button_up():
	get_tree().quit()
	return
