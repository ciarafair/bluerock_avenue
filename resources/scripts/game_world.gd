extends Node3D

const TweenDuration: float = 0.5

# Flashlight Raycasting
var BLOCK_RAY_ARRAY: Array = []
var FLASHLIGHT_RAY_ARRAY: Array = []
var BLOCK_RESULT_VALUE
var SpaceState: PhysicsDirectSpaceState3D

var Has_Not_Looped_Yet: bool = true

func mouse_position(_mask, _camera, _area_bool, _body_bool):
	if Global.SpaceState == null:
		return

	var LENGTH = 50
	var RAY_FROM = _camera.project_ray_origin(Global.MousePosition2D)
	var RAY_TO = RAY_FROM + _camera.project_ray_normal(Global.MousePosition2D) * LENGTH
	var QUERY = PhysicsRayQueryParameters3D.create(RAY_FROM, RAY_TO)
	QUERY.set_collision_mask(_mask)
	QUERY.exclude = [_camera]
	QUERY.collide_with_areas = _area_bool
	QUERY.collide_with_bodies = _body_bool
	var RESULT = Global.SpaceState.intersect_ray(QUERY)

	if RESULT.size() > 0:
		return RESULT

func block_raycast():
	if Global.Is_Hovering_Over_Right_Movement_Panel == false and Global.Is_Hovering_Over_Bottom_Movement_Panel == false and Global.Is_Hovering_Over_Left_Movement_Panel == false:
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

func search_for_starting_room(_node):
	for child in _node.get_children():
		if child is RoomBlock && child.RoomNumber == 1:
			SignalManager.activate_block.emit(child)
			Has_Not_Looped_Yet = false
		elif child is RoomBlock && child.RoomNumber != 1:
			#print_debug("Setting " + str(child.name) + " as not visible")
			child.set_visible(false)
		else:
			search_for_starting_room(child)

func enable_door_view(_int):
	#print_debug("Enabling door view of room #" + str(_int))
	for child in self.get_children(true):
		if child is RoomBlock && child.RoomNumber == _int:
			child.set_visible(true)
		elif child is RoomBlock && child.RoomNumber != _int:
			#push_warning(str(child.name) + " is a room, but does not have the ID of " + str(_int) + ". Not enabling.")
			pass
		elif not child is RoomBlock:
			#push_warning(str(child.name) + " is not a room.")
			pass

func disable_door_view(_int):
	#print_debug("Disabling door view of room #" + str(_int))
	for child in self.get_children(true):
		if child is RoomBlock && child.RoomNumber == _int:
			child.set_visible(false)
		elif child is RoomBlock && child.RoomNumber != _int:
			#push_warning(str(child.name) + " is a room, but does not have the ID of " + str(_int) + ". Not disabling.")
			pass
		elif not child is RoomBlock:
			#push_warning(str(child.name) + " is not a room.")
			pass

func tween_to_room(_node):
	var TweenInstance: Tween = get_tree().create_tween()
	TweenInstance.finished.connect(Global.on_tween_finished)
	TweenInstance.bind_node(_node)
	Global.Is_In_Animation = true
	TweenInstance.tween_property(Global.Loaded_Player, "position", _node.BlockCameraPosition.position + _node.position, TweenDuration).from_current()
	TweenInstance.tween_property(Global.Loaded_Player, "rotation", _node.BlockCameraPosition.rotation, TweenDuration).from_current()
	return

func on_move_to_room(_int):
	for child in self.get_children(true):
		if child is RoomBlock && child.RoomNumber == _int:
			SignalManager.close_door.emit()
			SignalManager.activate_block.emit(child)
			tween_to_room(child)
			child.set_visible(true)
			return
		else:
			#push_error("Room number does not match " + str(_int))
			pass

func on_find_monster_room(_int):
	for child in self.get_children(true):
		if child is RoomBlock && child.RoomNumber == _int:
			Global.Monster_Current_Room = child
			#print_debug("Monster is in the " + str(child.name))
			return
		elif child is RoomBlock && child.RoomNumber != _int:
			#push_warning(str(child) + " is a room but not with the number " + str(_int))
			pass

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	SignalManager.game_world_loaded.emit()
	SignalManager.stop_track.emit()
	SignalManager.enable_other_side_of_door.connect(enable_door_view)
	SignalManager.disable_other_side_of_door.connect(disable_door_view)
	SignalManager.move_to_room.connect(on_move_to_room)
	SignalManager.find_monster_room.connect(on_find_monster_room)

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
	Global.SpaceState = Global.Loaded_Player.get_world_3d().direct_space_state
	Global.CentreOfScreen = get_viewport().get_visible_rect().size / 2
	Global.MousePosition2D = get_viewport().get_mouse_position()

	# Flashlight Raycasting
	if Global.Loaded_Game_World == null:
		Global.Loaded_Game_World = self

	if Global.Is_Pause_Menu_Open == false:
		manage_flashlight_raycast()
		block_raycast()

func _on_child_order_changed():
	if Has_Not_Looped_Yet == true:
		search_for_starting_room(self)
		return
