extends Node3D

const TweenDuration: float = 0.5

# Flashlight Raycasting
var BLOCK_RAY_ARRAY: Array = []
var FLASHLIGHT_RAY_ARRAY: Array = []
var BLOCK_RESULT_VALUE
var SpaceState: PhysicsDirectSpaceState3D

func mouse_position(mask, camera, area_bool, body_bool):
	if Global.SpaceState == null:
		return

	var ray_length = 50
	var ray_from = camera.project_ray_origin(Global.MousePosition2D)
	var ray_to = ray_from + camera.project_ray_normal(Global.MousePosition2D) * ray_length
	var ray_query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	ray_query.set_collision_mask(mask)
	ray_query.exclude = [camera]
	ray_query.collide_with_areas = area_bool
	ray_query.collide_with_bodies = body_bool
	var ray_result = Global.SpaceState.intersect_ray(ray_query)

	if ray_result.size() > 0:
		return ray_result

func block_raycast():
	if Global.CurrentMouseState == Global.MouseState.MOVEMENT or Global.CurrentMouseState == Global.MouseState.DIALOGUE:
		var CollisionMask: int = 2
		var AreaBool: bool = false
		var BodyBool: bool = true
		var BlockResult = mouse_position(CollisionMask, Global.PlayerInstance.Camera, AreaBool, BodyBool)

		if BlockResult == null:
			Global.Hovering_Block = null
			return

		if BlockResult.size() > 0:
			Global.Is_Clickable = true
			Global.Hovering_Block = BlockResult.values()[3]

		if BlockResult.size() <= 0:
			Global.Hovering_Block = null

func flashlight_raycast():
	var CollisionMask: int = 3
	var AreaBool: bool = false
	var BodyBool: bool = true
	var FlashlightResult = mouse_position(CollisionMask, Global.PlayerInstance.Camera, AreaBool, BodyBool)

	if FlashlightResult == null:
		Global.FLASHLIGHT_RAY_ARRAY = []
		return

	if FlashlightResult.size() > 0:
		#print_debug(RESULT.values())
		Global.FLASHLIGHT_RAY_ARRAY = FlashlightResult.values()

func manage_flashlight_raycast():
	if Global.Game_Data_Instance.Is_Flashlight_On == true:
		Global.PlayerInstance.Flashlight.visible = true
		flashlight_raycast()
		if Global.FLASHLIGHT_RAY_ARRAY != []:
			Global.PlayerInstance.Flashlight.look_at(Global.FLASHLIGHT_RAY_ARRAY[0])
		return
	else:
		Global.PlayerInstance.Flashlight.visible = false
		return

func on_enable_door_view(node, number):
	#print_debug("Enabling door view of room #" + str(number))
	for child in node.get_children(true):
		if child is RoomBlock && child.RoomNumber == number:
			child.set_visible(true)
		elif child is RoomBlock && child.RoomNumber != number:
			#push_warning(str(child.name) + " is a room, but does not have the ID of " + str(number) + ". Not enabling.")
			pass
		elif not child is RoomBlock:
			SignalManager.enable_other_side_of_door.emit(child, number)
			pass

func on_disable_door_view(node, number):
	#print_debug("Disabling door view of room #" + str(number))
	for child in node.get_children(true):
		if child is RoomBlock && child.RoomNumber == number:
			child.set_visible(false)
		elif child is RoomBlock && child.RoomNumber != number:
			#push_warning(str(child.name) + " is a room, but does not have the ID of " + str(number) + ". Not disabling.")
			pass
		elif not child is RoomBlock:
			SignalManager.disable_other_side_of_door.emit(child, number)
			pass

func tween_to_room(node):
	var TweenInstance: Tween = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(node)
	Global.Is_In_Animation = true
	TweenInstance.tween_property(Global.PlayerInstance, "position", node.BlockCameraPosition.position + node.position, TweenDuration).from_current()
	#TweenInstance.tween_property(Global.PlayerInstance, "rotation", node.BlockCameraPosition.rotation, TweenDuration).from_current()
	return

func on_move_to_room(node, number):
	for child in node.get_children(true):
		if child is RoomBlock && child.RoomNumber == number:
			SignalManager.close_door.emit()
			SignalManager.activate_block.emit(child)
			tween_to_room(child)
			child.set_visible(true)
			return
		elif not child is RoomBlock:
			#push_error("Room number does not match " + str(number))
			SignalManager.move_to_room.emit(child, number)
			pass

func manage_signals():
	SignalManager.enable_other_side_of_door.connect(on_enable_door_view)
	SignalManager.disable_other_side_of_door.connect(on_disable_door_view)
	SignalManager.move_to_room.connect(on_move_to_room)

func load_children():
	print_debug("Begining to load.")
	SignalManager.load_player.emit()
	await SignalManager.player_loaded
	#print_debug("Player loaded.")

	SignalManager.load_pause_menu.emit()
	await SignalManager.pause_menu_loaded
	#print_debug("Pause menu loaded.")

	SignalManager.load_movement_interface.emit()
	await SignalManager.movement_interface_loaded
	#print_debug("Movement interface loaded.")

	SignalManager.load_game_over_screen.emit()
	await SignalManager.game_over_screen_loaded
	#print_debug("Game over screen loaded.")

	SignalManager.load_task_list.emit()
	await SignalManager.task_list_loaded
	#print_debug("Task list has loaded.")

	SignalManager.load_dialogue_box.emit()
	await SignalManager.dialogue_box_loaded
	#print_debug("Dialogue box has loaded.")

	SignalManager.game_world_loaded.emit()
	Global.load_data(Path.GameJSONFilePath, "game")

func _ready():
	self.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	manage_signals()
	Global.Is_Game_Active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	load_children()
	return

func _process(_delta):

	if Global.PlayerInstance != null:
		manage_flashlight_raycast()
		block_raycast()
		Global.SpaceState = Global.PlayerInstance.get_world_3d().direct_space_state
	Global.ScreenCentre = get_window().size / 2
	Global.MousePosition2D = get_viewport().get_mouse_position()
