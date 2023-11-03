extends Node3D

@onready var Camera = $Camera3D
@onready var Flashlight = $SpotLight3D
var TweenInstance: Tween

var camera_target_rotation = Vector2()
var camera_current_rotation = Vector2()
var minPitch = -360 * 2
var maxPitch = 360 * 2

func on_mouse_movement(_position):
	var sensitivity = Vector2(Global.Settings_Data.Mouse_Sensitivity, Global.Settings_Data.Mouse_Sensitivity)

	camera_target_rotation.y += -_position.x * sensitivity.x
	camera_target_rotation.x += -_position.y * sensitivity.y

	camera_target_rotation.x = clamp(camera_target_rotation.x, deg_to_rad(minPitch), deg_to_rad(maxPitch))
	camera_target_rotation.y = clamp(camera_target_rotation.y, deg_to_rad(minPitch), deg_to_rad(maxPitch))

func on_turn_180_degrees():
	#print_debug("Turning around 180 degrees.")
	Global.Is_In_Animation = true
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(self)
	TweenInstance.tween_property(self, "rotation_degrees:y", 180, 1).as_relative()
	return

func on_turn_positive_90_degrees():
	#print_debug("Turning to the left 90 degrees.")
	Global.Is_In_Animation = true
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(self)
	TweenInstance.tween_property(self, "rotation_degrees:y", 90, 0.5).as_relative()
	return

func on_turn_negative_90_degrees():
	#print_debug("Turning to the right 90 degrees.")
	Global.Is_In_Animation = true
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
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

func on_reset_player_camera():
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.bind_node(Camera)
	TweenInstance.tween_property(Camera, "rotation", Vector3(0,0,0), 0.25)

func manage_signals():
	SignalManager.mouse_movement.connect(on_mouse_movement)
	SignalManager.reset_player_camera.connect(on_reset_player_camera)
	SignalManager.turn_180_degrees.connect(on_turn_180_degrees)
	SignalManager.turn_negative_90_degrees.connect(on_turn_negative_90_degrees)
	SignalManager.turn_positive_90_degrees.connect(on_turn_positive_90_degrees)

func _process(_delta):
	if Global.Is_Able_To_Turn == true && Global.Is_In_Animation == false:
		camera_current_rotation = camera_current_rotation.lerp(camera_target_rotation, Global.Settings_Data.Mouse_Sensitivity)
		Camera.set_rotation_degrees(Vector3(camera_current_rotation.x, camera_current_rotation.y, Camera.rotation_degrees.z))
		automatic_rounded_rotation()

func _ready():
	manage_signals()
	Global.Loaded_Player = self
	Flashlight.set_visible(false)

	if Global.Loaded_Player == null:
		push_error(str(self.name) + " was not loaded to Global.")
