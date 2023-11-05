extends Node3D
class_name Block

@export var PlayerRotation: bool
@export var BlockDialoguePath: String

const TweenDuration: float = 0.5
var TweenInstance: Tween

var BlockCameraPosition: CameraPosition = null
var BlockCollider: CollisionShape3D = null
var BlockParent: Block = null
var IsActive: bool = false

func search_for_parent_block(_node):
	if _node != null:
		if self is RoomBlock:
			pass

		if self is LocationBlock:
			var _parent = _node.get_parent()

			if _parent is RoomBlock:
				BlockParent = _parent
				#print_debug("Found " + str(self.name) + "'s parent node: " + str(BlockParent.name))
				return
			else:
				search_for_parent_block(_parent)

		if self is PropBlock:
			var _parent = _node.get_parent()

			if _parent is LocationBlock:
				BlockParent = _parent
				#print_debug("Found " + str(self.name) + "'s parent node: " + str(BlockParent.name))
				return
			else:
				search_for_parent_block(_parent)

func search_for_camera_position(_node):
	for child in _node.get_children():
		if child is CameraPosition:
			BlockCameraPosition = child
			#print_debug("Found camera for " + str(self.name) + ": " + str(child))

func on_tween_finished():
	#print_debug("Tween completed")
	Global.Is_In_Animation = false
	TweenInstance.kill()

func camera_position_tween(_node, _position: bool, _rotation: bool):
	if TweenInstance:
		TweenInstance.kill()

	TweenInstance = get_tree().create_tween()
	TweenInstance.finished.connect(on_tween_finished)
	TweenInstance.bind_node(self)

	#! This function includes the RoomBlock because its focusing on the PARENT node and not the node that is being animated from.
	if _node is PropBlock:
		SignalManager.reset_player_camera.emit()
		if BlockCameraPosition != null:
			Global.Is_In_Animation = true
			if _rotation:
				TweenInstance.tween_property(Global.Loaded_Player, "rotation", _node.BlockCameraPosition.rotation, TweenDuration).from_current()
			else:
				#print_debug("Rotation altering disabled")
				pass
			return
		else:
			pass

	if _node is LocationBlock:
		SignalManager.reset_player_camera.emit()
		if BlockCameraPosition != null:
			Global.Is_In_Animation = true

			if _position:
				TweenInstance.tween_property(Global.Loaded_Player, "position", _node.BlockCameraPosition.position + _node.position + Global.Current_Room.position, TweenDuration).from_current()
				pass
			else:
				print_debug("Position altering disabled")
				pass

			if _rotation:
				TweenInstance.tween_property(Global.Loaded_Player, "rotation_degrees", _node.BlockCameraPosition.rotation_degrees, TweenDuration).from_current()
				pass
			else:
				print_debug("Rotation altering disabled")
				pass
			return
		else:
			pass

	if _node is RoomBlock:
		if BlockCameraPosition != null:
			Global.Is_In_Animation = true

			if _position:
				TweenInstance.tween_property(Global.Loaded_Player, "position", _node.BlockCameraPosition.position + _node.position, TweenDuration)
				pass
			else:
				#print_debug("Position altering disabled")
				pass

			if _rotation:
				if _node.PlayerRotation == true:
					#print_debug("Rounding to the nearest 90 degrees.")
					var target_rotation = 90 * round(Global.Loaded_Player.rotation_degrees.y / 90)
					TweenInstance.tween_property(Global.Loaded_Player, "rotation_degrees", Vector3(_node.BlockCameraPosition.rotation.x, target_rotation, _node.BlockCameraPosition.rotation.z), TweenDuration).from_current()
				else:
					TweenInstance.tween_property(Global.Loaded_Player, "rotation_degrees", _node.BlockCameraPosition.rotation_degrees, TweenDuration).from_current()
			else:
				#print_debug("Rotation altering disabled")
				pass
			return
		else:
			pass

func move_to_camera_position(_node, _position: bool, _rotation: bool):
	if _node.BlockCameraPosition != null:
		#print_debug("Moving to " + str(_node))
		camera_position_tween(_node, _position, _rotation)

	if _node.BlockCameraPosition == null:
		#print_debug("Could not find camera position for " + str(_node) + ". Trying again.")
		for child in _node.get_children():
			if child is CameraPosition:
				_node.BlockCameraPosition = child
				move_to_camera_position(_node, _position, _rotation)

func search_for_collider(_node):
	if _node is RoomBlock:
		BlockCollider = null
	if not _node is RoomBlock:
		for child in _node.get_children():
			if child is CollisionShape3D:
				BlockCollider = child
				#print_debug("Found collider for " + str(self.name) + ": " + str(child))

func disable_collider(_node):
	if _node.BlockCollider != null:
		_node.BlockCollider.set_disabled(true)
		return
	else:
		#print_debug(str(_node.name) + " does not have a collider to disable.")
		return

func enable_collider(_node):
	if _node.BlockCollider != null:
		_node.BlockCollider.set_disabled(false)
		return
	else:
		#print_debug(str(_node.name) + " does not have a collider to enable.")
		return

func search_for_locations(_node, _enable: bool):
	if _enable == true:
		for child in _node.get_children():
			if child is LocationBlock:
				enable_collider(child)
				#print_debug("Found " + str(self.name) + "'s location block: " + str(child.name))
			else:
				search_for_locations(child, true)

	if _enable == false:
		for child in _node.get_children():
			if child is LocationBlock:
				disable_collider(child)
				#print_debug("Found " + str(self.name) + "'s location block: " + str(child.name))
			else:
				search_for_locations(child, false)

func search_for_props(_node, _enable: bool):
	if _enable == true:
		for child in _node.get_children():
			if child is PropBlock:
				enable_collider(child)
				#print_debug("Found " + str(self.name) + "'s location block: " + str(child.name))
			else:
				search_for_props(child, true)

	if _enable == false:
		for child in _node.get_children():
			if child is PropBlock:
				disable_collider(child)
				#print_debug("Found " + str(self.name) + "'s location block: " + str(child.name))
			else:
				search_for_props(child, false)

func on_activate_block(_node):
	#print_debug("Activating " + str(Global.Current_Active_Block))
	move_to_camera_position(_node, true, true)
	Global.Current_Active_Block = _node

	if self.PlayerRotation == true:
		Global.Is_Able_To_Turn = true
	else:
		Global.Is_Able_To_Turn = false

	if !SignalManager.deactivate_block.is_connected(on_deactivate_block):
		SignalManager.deactivate_block.connect(on_deactivate_block)

	if _node is RoomBlock:
		SignalManager.room_loaded.emit(_node)
		return
	else:
		disable_collider(_node)
		return

func on_deactivate_block(_node):
	if Global.Current_Event != "":
		SignalManager.stop_event.emit()

	if _node.BlockParent != null:
		if _node is RoomBlock:
			#print_debug("Cannot leave room block.")
			return
		else:
			move_to_camera_position(_node.BlockParent, true, true)
			SignalManager.activate_block.emit(_node.BlockParent)

	if BlockParent == null:
		#print_debug("Could not find " + str(self.name) + "'s parent")
		pass

func set_rotation_ability():
	if Global.Current_Active_Block == self:
		Global.Is_Able_To_Turn = self.PlayerRotation

func _ready():
	SignalManager.activate_block.connect(on_activate_block)
	SignalManager.deactivate_block.connect(on_deactivate_block)

	search_for_parent_block(self)
	search_for_camera_position(self)
	search_for_collider(self)
	set_rotation_ability()

	if BlockCollider != null:
		BlockCollider.disabled = true
	else:
		#print_debug(str(self.name) + " does not have a collider.")
		pass

