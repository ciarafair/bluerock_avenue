extends Node3D

const TweenDuration: float = 0.5

# Flashlight Raycasting
var MOUSE_POSITION_2D: Vector2 = Vector2(0,0)
var BLOCK_RAY_ARRAY: Array = []
var FLASHLIGHT_RAY_ARRAY: Array = []
var BLOCK_RESULT_VALUE
var SPACE_STATE: PhysicsDirectSpaceState3D

var Has_Not_Looped_Yet: bool = true

func block_raycast():
	if Global.Is_Hovering_Over_Right_Movement_Panel == false and Global.Is_Hovering_Over_Bottom_Movement_Panel == false and Global.Is_Hovering_Over_Left_Movement_Panel == false:
		var COLLISION_MASK: int = 2
		var AREA_BOOL: bool = false
		var BODY_BOOL: bool = true
		var RESULT = Global.mouse_position(MOUSE_POSITION_2D, SPACE_STATE, COLLISION_MASK, Global.Loaded_Player.CAMERA, AREA_BOOL, BODY_BOOL)

		if RESULT == null:
			Global.Hovering_Block = null
			return

		if RESULT.size() > 0:
			Global.Is_Clickable = true
			Global.Hovering_Block = RESULT.values()[3]

		if RESULT.size() <= 0:
			Global.Hovering_Block = null

func flashlight_raycast():
	var COLLISION_MASK: int = 3
	var AREA_BOOL: bool = false
	var BODY_BOOL: bool = true
	var RESULT = Global.mouse_position(MOUSE_POSITION_2D, SPACE_STATE, COLLISION_MASK, Global.Loaded_Player.CAMERA, AREA_BOOL, BODY_BOOL)

	if RESULT == null:
		Global.FLASHLIGHT_RAY_ARRAY = []
		return

	if RESULT.size() > 0:
		#print_debug(RESULT.values())
		Global.FLASHLIGHT_RAY_ARRAY = RESULT.values()

func manage_flashlight_raycast():
	if Global.Is_Flashlight_On == true:
		Global.Loaded_Player.FLASHLIGHT.visible = true
		flashlight_raycast()
		if Global.FLASHLIGHT_RAY_ARRAY != []:
			Global.Loaded_Player.FLASHLIGHT.look_at(Global.FLASHLIGHT_RAY_ARRAY[0])
		return
	else:
		Global.Loaded_Player.FLASHLIGHT.visible = false
		return

func search_for_starting_room(_node):
	for child in _node.get_children():
		if child is RoomBlock && child.RoomNumber == 1:
			SignalManager.activate_block.emit(child)
			Has_Not_Looped_Yet = false
		if child is RoomBlock && child.RoomNumber != 1:
			print_debug("Setting " + str(child.name) + " as not visible")
			child.set_visible(false)

func enable_door_view(_int):
	print_debug("Enabling door view of room #" + str(_int))
	for child in self.get_children(true):
		if child is RoomBlock && child.RoomNumber == _int:
			child.set_visible(true)

func disable_door_view(_int):
	print_debug("Disabling door view of room #" + str(_int))
	for child in self.get_children(true):
		if child is RoomBlock && child.RoomNumber == _int:
			child.set_visible(false)

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

func _ready():
	SignalManager.game_world_loaded.emit()
	SignalManager.stop_track.emit()
	SignalManager.enable_other_side_of_door.connect(enable_door_view)
	SignalManager.disable_other_side_of_door.connect(disable_door_view)
	SignalManager.move_to_room.connect(on_move_to_room)

	Global.GameState = "game_active"
	Global.Loaded_Game_World = self
	Global.Is_Game_Active = true
	Global.Loaded_Game_World = self

func _on_tree_entered():
	#print_debug(str(self.name) + " has entered the tree.")
	pass

func _on_tree_exited():
	#print_debug(str(self.name) + " has exited the tree.")
	Global.GameState = ""
	Global.Is_Game_Active = false

func _process(_delta):
	# Flashlight Raycasting
	SPACE_STATE = Global.Loaded_Player.get_world_3d().direct_space_state
	MOUSE_POSITION_2D = get_viewport().get_mouse_position()

	if Global.Loaded_Game_World == null:
		Global.Loaded_Game_World = self

	if Global.Is_Pause_Menu_Open == false:
		manage_flashlight_raycast()
		block_raycast()

func _on_child_order_changed():
	if Has_Not_Looped_Yet == true:
		search_for_starting_room(self)
