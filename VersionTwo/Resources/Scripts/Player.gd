extends Node3D

@onready var CAMERA = $Camera3D
@onready var FLASHLIGHT = $SpotLight3D

func on_turn_180_degrees():
	#print_debug("Turning around 180 degrees.")
	Global.Is_In_Animation = true
	var TweenInstance: Tween = get_tree().create_tween()

	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(self)
	TweenInstance.tween_property(self, "rotation_degrees:y", 180, 1).as_relative()
	return

func on_turn_positive_90_degrees():
	#print_debug("Turning to the left 90 degrees.")
	Global.Is_In_Animation = true
	var TweenInstance: Tween = get_tree().create_tween()

	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(self)
	TweenInstance.tween_property(self, "rotation_degrees:y", 90, 0.5).as_relative()
	return

func on_turn_negative_90_degrees():
	#print_debug("Turning to the right 90 degrees.")
	Global.Is_In_Animation = true
	var TweenInstance: Tween = get_tree().create_tween()

	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(self)
	TweenInstance.tween_property(self, "rotation_degrees:y", -90, 0.5).as_relative()
	return

func automatic_rounded_rotation():
	#print_debug("Rounding to nearest 90 degrees.")
	if self.rotation_degrees.y >= 360:
		self.rotation_degrees.y = 0

	if self.rotation_degrees.y <= -360:
		self.rotation_degrees.y = 0

	if self.rotation_degrees.y == -90 and Global.Current_Active_Block is RoomBlock:
		self.rotation_degrees.y = 270

func _process(_delta):
	if Global.Is_Able_To_Turn == true:
		automatic_rounded_rotation()
	else:
		pass

func _ready():
	SignalManager.turn_180_degrees.connect(on_turn_180_degrees)
	SignalManager.turn_negative_90_degrees.connect(on_turn_negative_90_degrees)
	SignalManager.turn_positive_90_degrees.connect(on_turn_positive_90_degrees)

	Global.Loaded_Player = self
	FLASHLIGHT.set_visible(false)

	if Global.Loaded_Player == null:
		print(str(self.name) + " was not loaded to Global.")
