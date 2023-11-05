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
	if Global.Mouse_State == 1 or Global.Mouse_State == 2:
		var CollisionMask: int = 2
		var AreaBool: bool = false
		var BodyBool: bool = true
		var BlockResult = mouse_position(CollisionMask, Global.Loaded_Player.Camera, AreaBool, BodyBool)

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
	var FlashlightResult = mouse_position(CollisionMask, Global.Loaded_Player.Camera, AreaBool, BodyBool)

	if FlashlightResult == null:
		Global.FLASHLIGHT_RAY_ARRAY = []
		return

	if FlashlightResult.size() > 0:
		#print_debug(RESULT.values())
		Global.FLASHLIGHT_RAY_ARRAY = FlashlightResult.values()

func manage_flashlight_raycast():
	if Global.Is_Flashlight_On == true:
		Global.Loaded_Player.Flashlight.visible = true
		flashlight_raycast()
		if Global.FLASHLIGHT_RAY_ARRAY != []:
			Global.Loaded_Player.Flashlight.look_at(Global.FLASHLIGHT_RAY_ARRAY[0])
		return
	else:
		Global.Loaded_Player.Flashlight.visible = false
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
	TweenInstance.tween_property(Global.Loaded_Player, "position", node.BlockCameraPosition.position + node.position, TweenDuration).from_current()
	#TweenInstance.tween_property(Global.Loaded_Player, "rotation", node.BlockCameraPosition.rotation, TweenDuration).from_current()
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

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	SignalManager.game_world_loaded.emit()
	SignalManager.stop_track.emit()
	SignalManager.enable_other_side_of_door.connect(on_enable_door_view)
	SignalManager.disable_other_side_of_door.connect(on_disable_door_view)
	SignalManager.move_to_room.connect(on_move_to_room)

	Global.Loaded_Game_World = self
	Global.Is_Game_Active = true
	Global.Loaded_Game_World = self

func _on_tree_entered():
	#print_debug(str(self.name) + " has entered the tree.")
	pass

func _on_tree_exited():
	#print_debug(str(self.name) + " has exited the tree.")
	Global.Is_Game_Active = false
	pass

func _process(_delta):
	if Global.Loaded_Player != null:
		Global.SpaceState = Global.Loaded_Player.get_world_3d().direct_space_state
	Global.CentreOfScreen = get_viewport().get_visible_rect().size / 2
	Global.MousePosition2D = get_viewport().get_mouse_position()

	# Flashlight Raycasting
	if Global.Loaded_Game_World == null:
		Global.Loaded_Game_World = self

	manage_flashlight_raycast()
	block_raycast()
