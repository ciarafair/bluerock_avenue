extends Node3D

const TweenDuration: float = 0.5

var has_emitted_loaded: bool = false

# Flashlight Raycasting
var BLOCK_RAY_ARRAY: Array = []
var FLASHLIGHT_RAY_ARRAY: Array = []
var BLOCK_RESULT_VALUE
var SpaceState: PhysicsDirectSpaceState3D
var are_objects_loaded: bool = false

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
	if Global.CurrentMouseState == Global.mouse.MOVEMENT or Global.CurrentMouseState == Global.mouse.DIALOGUE:
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


func item_raycast():
	if Global.CurrentMouseState == Global.mouse.MOVEMENT or Global.CurrentMouseState == Global.mouse.DIALOGUE:
		var CollisionMask: int = 5
		var AreaBool: bool = false
		var BodyBool: bool = true
		var InteractableResult = mouse_position(CollisionMask, Global.PlayerInstance.Camera, AreaBool, BodyBool)

		if InteractableResult == null:
			Global.Hovering_Interactable = null
			return
		if InteractableResult.size() > 0:
			Global.Is_Clickable = true
			Global.Hovering_Interactable = InteractableResult.values()[3]
			#print_rich("Hovering over item %s" %[Global.Hovering_Interactable])
			#Global.stack_info(get_stack())
			return
		if InteractableResult.size() <= 0:
			Global.Hovering_Interactable = null
			return
		return

func flashlight_raycast():
	var CollisionMask: int = 3
	var AreaBool: bool = false
	var BodyBool: bool = true
	var FlashlightResult = mouse_position(CollisionMask, Global.PlayerInstance.Camera, AreaBool, BodyBool)

	if FlashlightResult == null:
		Global.FLASHLIGHT_RAY_ARRAY = []
		return

	if FlashlightResult.size() > 0:
		#print_rich(RESULT.values())
		#Global.stack_info(get_stack())
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
	#print_rich("Enabling door view of room #" + str(number))
	#Global.stack_info(get_stack())
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
	#print_rich("Disabling door view of room #" + str(number))
	#Global.stack_info(get_stack())
	for child in node.get_children(true):
		if child is RoomBlock && child.RoomNumber == number:
			child.set_visible(false)
		elif child is RoomBlock && child.RoomNumber != number:
			#printerr(str(child.name) + " is a room, but does not have the ID of " + str(number) + ". Not disabling.")
			#Global.stack_info(get_stack())
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
			#Global.stack_info(get_stack())
			SignalManager.move_to_room.emit(child, number)
			pass

func manage_signals():
	SignalManager.enable_other_side_of_door.connect(on_enable_door_view)
	SignalManager.disable_other_side_of_door.connect(on_disable_door_view)
	SignalManager.move_to_room.connect(on_move_to_room)

func load_children():
	#print_rich("Begining to load.")
	#Global.stack_info(get_stack())

	SignalManager.load_dialogue_box.emit()
	await SignalManager.dialogue_box_loaded
	#print_rich("Dialogue box has loaded.")
	#Global.stack_info(get_stack())

	SignalManager.load_player.emit()
	await SignalManager.player_loaded
	#print_rich("Player loaded.")
	#Global.stack_info(get_stack())

	SignalManager.load_pause_menu.emit()
	await SignalManager.pause_menu_loaded
	#print_rich("Pause menu loaded.")
	#Global.stack_info(get_stack())

	SignalManager.load_movement_interface.emit()
	await SignalManager.movement_interface_loaded
	#print_rich("Movement interface loaded.")
	#Global.stack_info(get_stack())

	SignalManager.load_game_over_screen.emit()
	await SignalManager.game_over_screen_loaded
	#print_rich("Game over screen loaded.")
	#Global.stack_info(get_stack())

	SignalManager.load_task_list.emit()
	await SignalManager.task_list_loaded
	#print_rich("Task list has loaded.")
	#Global.stack_info(get_stack())

	SignalManager.load_monster.emit()
	await SignalManager.monster_loaded
	#print_rich("Monster has loaded.")
	#Global.stack_info(get_stack())

	if Global.Settings_Data_Instance.Skip_Introduction == false:
		SignalManager.load_intro_animation.emit()
		await SignalManager.intro_animation_loaded
		await SignalManager.intro_animation_completed

	Global.load_data(Path.GameJSONFilePath, "game")
	are_objects_loaded = true

@onready var AnimationPlayerInstance = %AnimationPlayer
@onready var ScreenCover = %ScreenCover
func _ready():
	self.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	manage_signals()
	Global.Is_Game_Active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	load_children()
	await SignalManager.game_world_loaded
	AnimationPlayerInstance.play("fade_in")
	await AnimationPlayerInstance.animation_finished
	AnimationPlayerInstance.queue_free()
	ScreenCover.queue_free()
	return

func _process(_delta):
	if has_emitted_loaded == false && are_objects_loaded == true:
		has_emitted_loaded = true
		SignalManager.game_world_loaded.emit()

	if Global.PlayerInstance != null:
		manage_flashlight_raycast()
		block_raycast()
		item_raycast()
		Global.SpaceState = Global.PlayerInstance.get_world_3d().direct_space_state

	Global.ScreenCentre = get_window().size / 2
	Global.MousePosition2D = get_viewport().get_mouse_position()
