extends CanvasLayer

@onready var Animation_Player_Instance: AnimationPlayer = %AnimationPlayer
@onready var Progress_Bar_Instance: ProgressBar = %ProgressBar

signal loading_screen_has_full_coverage

func update_progress_bar(value: float):
	Progress_Bar_Instance.set_value_no_signal(value * 100)

func start_exit_animation(boolian: bool):
	if Animation_Player_Instance.is_playing():
		await Signal(Animation_Player_Instance, "animation_finished")
	if boolian == true:
		await SignalManager.intro_animation_loaded
		self.queue_free()
		return
	Animation_Player_Instance.play("end_load")
	if Animation_Player_Instance.is_playing():
		await Signal(Animation_Player_Instance, "animation_finished")
		self.queue_free()
		return
