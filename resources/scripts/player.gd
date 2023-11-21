extends Node3D
class_name Player

@onready var Camera = %Camera3D
@onready var Flashlight = %SpotLight3D
@onready var ListenPosition = %ListenPosition

var TweenInstance: Tween = null
var TweenInstanceTwo: Tween = null
var TweenInstanceTwoRunning: bool = false

func on_turn_180_degrees():
	#print_rich("Turning around 180 degrees.")
	#Global.stack_info(get_stack())
	Global.Is_In_Animation = true
	if TweenInstance != null:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(self)
	TweenInstance.tween_property(self, "rotation_degrees:y", 180, 1).as_relative()
	return

func on_turn_positive_90_degrees():
	#print_rich("Turning to the left 90 degrees.")
	#Global.stack_info(get_stack())
	Global.Is_In_Animation = true
	if TweenInstance != null:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(self)
	TweenInstance.tween_property(self, "rotation_degrees:y", 90, 0.5).as_relative()
	return

func on_turn_negative_90_degrees():
	#print_rich("Turning to the right 90 degrees.")
	#Global.stack_info(get_stack())
	Global.Is_In_Animation = true
	if TweenInstance != null:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(self)
	TweenInstance.tween_property(self, "rotation_degrees:y", -90, 0.5).as_relative()
	return

func on_reset_player_camera():
	if TweenInstance != null:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.bind_node(Camera)
	TweenInstance.tween_property(Camera, "rotation", Vector3(0,0,0), 0.25)
	TweenInstance.tween_property(Camera, "position", Vector3(0,0,0), 0.25)

func on_player_camera_listen():
	if TweenInstance != null:
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
			#print_rich("Using %s as the starting room." % [child])
			#Global.stack_info(get_stack())
			Global.Game_Data_Instance.Current_Room = child
			SignalManager.activate_block.connect(child.on_activate_block)
			SignalManager.deactivate_block.connect(child.on_deactivate_block)
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
			Global.Game_Data_Instance.Current_Block = child
			await SignalManager.animation_finished
			return
		elif child is Block and child.name != identifier:
			pass
		search_for_block(child, identifier)

var camera_target_rotation = Vector3()
var camera_current_rotation = Vector3()
var maxPitch: float = 30
var maxYaw: float = 5.625

func on_camera_follow_mouse(mouse: Vector2):
	var screen: Vector2 = get_window().size / 2
	var distance = screen - mouse
	var target_rotation: Vector3 = Vector3(0,0,0)

	target_rotation.y = (maxPitch / screen.x) * distance.x
	target_rotation.x = (maxYaw / screen.y) * distance.y
	target_rotation.z = Camera.rotation_degrees.z
	camera_target_rotation = target_rotation

func manage_rotation():
	if self.rotation_degrees.y > 360:
		self.rotation_degrees.y -= 360
		return

	if self.rotation_degrees.y == 360:
		self.rotation_degrees.y = 0

	if self.rotation_degrees.y < -360:
		self.rotation_degrees.y += 360
		return

	if self.rotation_degrees.y == -360:
		self.rotation_degrees.y = 0

func on_camera_tween_finished():
	TweenInstanceTwoRunning = false
	TweenInstanceTwo.stop()

func manage_camera_turning():
	if TweenInstanceTwo != null:
		TweenInstanceTwo.stop()
		TweenInstanceTwoRunning = false

	TweenInstanceTwo = get_tree().create_tween()
	TweenInstanceTwo.bind_node(Camera)
	TweenInstanceTwoRunning = false

	if TweenInstanceTwoRunning == false:
		TweenInstanceTwoRunning = true
		var speed: float = 0.25
		TweenInstanceTwo.tween_property(Camera, "rotation_degrees", camera_target_rotation, speed).finished.connect(Callable(on_camera_tween_finished))
		return
	return

func _process(_delta):
	camera_current_rotation = Camera.get_rotation_degrees()

	if Global.PlayerInstance == null:
		Global.PlayerInstance = self
		SignalManager.player_loaded.emit()

	manage_rotation()
	if Global.Is_Able_To_Turn == true:
		manage_camera_turning()

	if Global.Game_Data_Instance.Current_Room == null:
		search_for_room(Global.Loaded_Game_World, Global.Game_Data_Instance.Current_Room_Number)
		if Global.Game_Data_Instance.Current_Block == null:
			#print_rich("Block name returned null. Searching for room instead.")
			SignalManager.activate_block.emit(Global.Game_Data_Instance.Current_Room)
			return

		SignalManager.activate_block.emit(Global.Game_Data_Instance.Current_Block)
		return

func _ready():
	self.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	manage_signals()
