extends Node3D

@onready var Camera = %Camera3D
@onready var Flashlight = %SpotLight3D
@onready var ListenPosition = %ListenPosition
var TweenInstance: Tween

var camera_target_rotation = Vector2()
var camera_current_rotation = Vector2()
var minPitch = -360 * 2
var maxPitch = 360 * 2

func on_camera_follow_mouse(mouse):
	var sensitivity = Vector2(Global.Settings_Data.Mouse_Sensitivity, Global.Settings_Data.Mouse_Sensitivity)

	camera_target_rotation.y += -mouse.x * sensitivity.x
	camera_target_rotation.x += -mouse.y * sensitivity.y

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

	if self.rotation_degrees.y == -90 and Global.Game_Data.Current_Active_Block is RoomBlock:
		self.rotation_degrees.y = 270

func on_reset_player_camera():
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.bind_node(Camera)
	TweenInstance.tween_property(Camera, "rotation", Vector3(0,0,0), 0.25)
	TweenInstance.tween_property(Camera, "position", Vector3(0,0,0), 0.25)

func on_player_camera_listen():
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.bind_node(Camera)
	TweenInstance.tween_property(Camera, "position", Vector3(ListenPosition.position), 0.25)
	TweenInstance.tween_property(Camera, "rotation", Vector3(ListenPosition.rotation), 0.25)

func manage_signals():
	SignalManager.mouse_movement.connect(Callable(on_camera_follow_mouse))
	SignalManager.reset_player_camera.connect(Callable(on_reset_player_camera))
	SignalManager.turn_180_degrees.connect(Callable(on_turn_180_degrees))
	SignalManager.turn_negative_90_degrees.connect(Callable(on_turn_negative_90_degrees))
	SignalManager.turn_positive_90_degrees.connect(Callable(on_turn_positive_90_degrees))
	SignalManager.player_camera_listen.connect(Callable(on_player_camera_listen))

func search_for_room(node: Node, identifier: int):
	for child in node.get_children(true):
		if child is RoomBlock and child.RoomNumber == identifier:
			#print_debug("Using %s as the starting room." % [child])
			Global.Game_Data.Current_Room = child
			await SignalManager.animation_finished
			return
		elif child is RoomBlock and child.RoomNumber != identifier:
			pass
		elif child is Node:
			search_for_room(child, identifier)
			pass

func search_for_block(node: Node, identifier: String):
	for child in node.get_children(true):
		if child is Block and child.name == identifier:
			Global.Game_Data.Current_Active_Block = child
			await SignalManager.animation_finished
			return
		elif child is Block and child.name != identifier:
			pass
		search_for_block(child, identifier)

func _process(_delta):
	if Global.Is_Able_To_Turn == true and Global.Is_In_Animation == false:
		camera_current_rotation = camera_current_rotation.lerp(camera_target_rotation, Global.Settings_Data.Mouse_Sensitivity)
		Camera.set_rotation_degrees(Vector3(camera_current_rotation.x, camera_current_rotation.y, Camera.rotation_degrees.z))
		automatic_rounded_rotation()

	if Global.Game_Data.Current_Room == null:
		search_for_room(Global.Loaded_Game_World, Global.Game_Data.Current_Room_Number)
		search_for_block(Global.Loaded_Game_World, Global.Game_Data.Current_Block_Name)
		if Global.Game_Data.Current_Block_Name == "":
			print_debug("Block name returned null. Searching for room instead.")
			SignalManager.activate_block.emit(Global.Game_Data.Current_Room)
			return

		SignalManager.activate_block.emit(Global.Game_Data.Current_Active_Block)
		return

func _ready():
	manage_signals()
	Global.Loaded_Player = self
	Flashlight.set_visible(false)
	if Global.Loaded_Player == null:
		push_error(str(self.name) + " was not loaded to Global.")
