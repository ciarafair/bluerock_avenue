extends CanvasLayer

@onready var AnimationPlayerInstance: AnimationPlayer = %PopupAnimationPlayer
@onready var TimerInstance: Timer = %PopupTimer
@onready var CenterContainerInstance: CenterContainer = %PopupCenterContainer
@onready var LabelInstance: Label = %PopupLabel

func play_animation(text: String, wait_time: float):
	LabelInstance.text = text
	AnimationPlayerInstance.play("popup")
	await AnimationPlayerInstance.animation_finished
	TimerInstance.start(wait_time)
	await TimerInstance.timeout
	AnimationPlayerInstance.play_backwards("popup")
	await AnimationPlayerInstance.animation_finished
	self.queue_free()
	pass

func _ready():
	SignalManager.popup_loaded.emit()
	self.CenterContainerInstance.set_modulate(Color(1, 1, 1, 0))
