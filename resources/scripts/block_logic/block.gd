extends Node3D
class_name Block

@export var PlayerRotation: bool
@export var BlockDialoguePath: JSON

const rotation_speed = 0.5
const TweenDuration: float = 0.5
var TweenInstance: Tween

var BlockCameraPosition: CameraPosition = null
var BlockCollider: CollisionShape3D = null
var BlockParent: Block = null
var IsActive: bool = false
var CanMove: bool = true

func search_for_parent_block(node):
	if node != null:
		if self is RoomBlock:
			pass

		if self is LocationBlock:
			var parent = node.get_parent()
			if parent is RoomBlock:
				BlockParent = parent
				#print_debug("Found " + str(self.name) + "'s parent node: " + str(BlockParent.name))
				return
			else:
				search_for_parent_block(parent)

		if self is PropBlock:
			var parent = node.get_parent()

			if parent is LocationBlock:
				BlockParent = parent
				#print_debug("Found " + str(self.name) + "'s parent node: " + str(BlockParent.name))
				return
			else:
				search_for_parent_block(parent)

func search_for_camera_position(node):
	for child in node.get_children():
		if child is CameraPosition:
			BlockCameraPosition = child
			#print_debug("Found camera for " + str(self.name) + ": " + str(child))

func search_for_prop_parent(node):
	var parent: Node = node.get_parent()
	if parent is LocationBlock:
		print_debug("%s is a location block." %[parent])
		return parent
	search_for_prop_parent(parent)

func on_tween_finished():
	#print_debug("Tween completed")
	Global.Is_In_Animation = false
	TweenInstance.kill()
	SignalManager.animation_finished.emit()

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func set_rotation_direction(target_rotation: Vector3, node: Node):
	if target_rotation.y > 90 or target_rotation.y < -90:
		if target_rotation.y > 0 && Global.PlayerInstance.rotation_degrees.y < target_rotation.y:
			print_debug("Rotating from %s clockwise." %[node])
			Global.PlayerInstance.rotation_degrees.y += 360
		elif target_rotation.y < 0 && Global.PlayerInstance.rotation_degrees.y > target_rotation.y:
			print_debug("Rotating from %s anti-clockwise." %[node])
			Global.PlayerInstance.rotation_degrees.y -= 360


func move_to_camera_position(node: Node, enable_position: bool, enable_rotation: bool):
	if node.BlockCameraPosition != null:
		#print_debug("Moving to " + str(_node))
		if TweenInstance:
			TweenInstance.kill()

		TweenInstance = get_tree().create_tween()
		TweenInstance.finished.connect(on_tween_finished)
		TweenInstance.bind_node(self)

		#! This function includes the RoomBlock because its focusing on the PARENT node and not the node that is being animated from.
		if BlockCameraPosition != null:
			if node is PropBlock:
				SignalManager.reset_player_camera.emit()
				Global.Is_In_Animation = true
				var target_position = node.BlockCameraPosition.position
				TweenInstance.tween_property(Global.PlayerInstance, "position", target_position + node.position + node.BlockParent.position + Global.Game_Data_Instance.Current_Room.position , TweenDuration).from_current()
				var node_location: LocationBlock = search_for_prop_parent(node)
				var target_rotation: Vector3

				if node_location != null:
					target_rotation = node.BlockCameraPosition.rotation_degrees + node_location.rotation_degrees
				else:
					target_rotation = node.BlockCameraPosition.rotation_degrees

				set_rotation_direction(target_rotation, node)
				TweenInstance.tween_property(Global.PlayerInstance, "rotation_degrees", target_rotation, TweenDuration)
				return

			if node is LocationBlock:
				SignalManager.reset_player_camera.emit()
				Global.Is_In_Animation = true
				var target_position = node.BlockCameraPosition.position
				TweenInstance.tween_property(Global.PlayerInstance, "position", target_position + node.position + Global.Game_Data_Instance.Current_Room.position, TweenDuration).from_current()
				var target_rotation = node.BlockCameraPosition.rotation_degrees

				set_rotation_direction(target_rotation, node)
				TweenInstance.tween_property(Global.PlayerInstance, "rotation_degrees", target_rotation, TweenDuration)
				return

			if node is RoomBlock:
				Global.Is_In_Animation = true
				TweenInstance.tween_property(Global.PlayerInstance, "position", node.BlockCameraPosition.position + node.position, TweenDuration)
				if node.PlayerRotation == true:
					#print_debug("Rounding to the nearest 90 degrees.")
					var target_rotation = 90 * round(Global.PlayerInstance.rotation_degrees.y / 90)
					TweenInstance.tween_property(Global.PlayerInstance, "rotation_degrees", Vector3(node.BlockCameraPosition.rotation.x, target_rotation, node.BlockCameraPosition.rotation.z), TweenDuration).from_current()
					return
				else:
					TweenInstance.tween_property(Global.PlayerInstance, "rotation_degrees", node.BlockCameraPosition.rotation_degrees, TweenDuration).from_current()
					return
			else:
				pass

	if node.BlockCameraPosition == null:
		#print_debug("Could not find camera position for " + str(_node) + ". Trying again.")
		for child in node.get_children():
			if child is CameraPosition:
				node.BlockCameraPosition = child
				move_to_camera_position(node, enable_position, enable_rotation)

func search_for_collider(node):
	if node is RoomBlock:
		BlockCollider = null
	if not node is RoomBlock:
		for child in node.get_children():
			if child is CollisionShape3D:
				BlockCollider = child
				#print_debug("Found collider for " + str(self.name) + ": " + str(child))

func disable_collider(node):
	if node.BlockCollider != null:
		node.BlockCollider.set_disabled(true)
		return
	else:
		#print_debug(str(_node.name) + " does not have a collider to disable.")
		return

func enable_collider(node):
	if node.BlockCollider != null:
		node.BlockCollider.set_disabled(false)
		return
	else:
		#print_debug(str(_node.name) + " does not have a collider to enable.")
		return

func search_for_locations(node, enable: bool):
	if enable == true:
		for child in node.get_children():
			if child is LocationBlock:
				enable_collider(child)
				#print_debug("Found " + str(self.name) + "'s location block: " + str(child.name))
			else:
				search_for_locations(child, true)

	if enable == false:
		for child in node.get_children():
			if child is LocationBlock:
				disable_collider(child)
				#print_debug("Found " + str(self.name) + "'s location block: " + str(child.name))
			else:
				search_for_locations(child, false)

func search_for_props(node, enable: bool):
	if enable == true:
		for child in node.get_children():
			if child is PropBlock:
				enable_collider(child)
				#print_debug("Found " + str(self.name) + "'s location block: " + str(child.name))
			else:
				search_for_props(child, true)

	if enable == false:
		for child in node.get_children():
			if child is PropBlock:
				disable_collider(child)
				#print_debug("Found " + str(self.name) + "'s location block: " + str(child.name))
			else:
				search_for_props(child, false)

func start_activation(node: Block):
	#print_debug("Activating " + str(Global.Current_Block))
	move_to_camera_position(node, true, true)
	Global.Game_Data_Instance.Current_Block = node
	Global.Game_Data_Instance.Current_Block_Name = node.name
	Global.Game_Data_Instance.Current_Block_Path = node.get_path()
	#print_debug(Global.Game_Data_Instance.Current_Block_Path)

	if node.PlayerRotation == true:
		Global.Is_Able_To_Turn = true
	else:
		Global.Is_Able_To_Turn = false
	if !SignalManager.deactivate_block.is_connected(on_deactivate_block):
		SignalManager.deactivate_block.connect(on_deactivate_block)
	if node is RoomBlock:
		SignalManager.room_loaded.emit(node)
	else:
		disable_collider(node)
	return

func on_activate_block(node):
	start_activation(node)


func on_deactivate_block(node):
	if Global.Game_Data_Instance.Current_Event != "":
		SignalManager.stop_event.emit()

	if node.BlockParent != null:
		if node is RoomBlock:
			#print_debug("Cannot leave room block.")
			return
		else:
			move_to_camera_position(node.BlockParent, true, true)
			SignalManager.activate_block.emit(node.BlockParent)

	if BlockParent == null:
		#print_debug("Could not find " + str(self.name) + "'s parent")
		pass

func set_rotation_ability():
	if Global.Game_Data_Instance:
		if Global.Game_Data_Instance.Current_Block == self:
			Global.Is_Able_To_Turn = self.PlayerRotation

func block_ready():
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

func _ready():
	block_ready()
