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

func search_for_camera_position(node: Node) -> CameraPosition:
	for child in node.get_children():
		if child is CameraPosition:
			return child
			#print_rich("Found camera for " + str(self.name) + ": " + str(child))
			#Global.stack_info(get_stack())
		else:
			return search_for_camera_position(child)
	return null

func search_for_parent(node: Node) -> Block:
	if node != null:
		var parent: Node = node.get_parent()
		if parent is Block:
			#print_rich("%s is a location block." %[parent])
			#Global.stack_info(get_stack())
			return parent
		else:
			return search_for_parent(parent)
	return null

func on_tween_finished():
	#print_rich("Tween completed")
	#Global.stack_info(get_stack())
	Global.Is_In_Animation = false
	TweenInstance.kill()
	SignalManager.animation_finished.emit()

func set_rotation_direction(target_rotation: Vector3, node: Node):
	if target_rotation.y > node.rotation_degrees.y + 45 or target_rotation.y < node.rotation_degrees.y -45:
		if target_rotation.y > 0 && Global.PlayerInstance.rotation_degrees.y < target_rotation.y:
			#print_rich("Rotating from %s clockwise." %[node])
			#Global.stack_info(get_stack())
			Global.PlayerInstance.rotation_degrees.y += 360
		elif target_rotation.y < 0 && Global.PlayerInstance.rotation_degrees.y > target_rotation.y:
			#print_rich("Rotating from %s anti-clockwise." %[node])
			#Global.stack_info(get_stack())
			Global.PlayerInstance.rotation_degrees.y -= 360

func move_to_camera_position(node: Block, enable_position: bool, enable_rotation: bool):
	if node.BlockCameraPosition != null:
		#print_rich("Moving to " + str(_node))
		#Global.stack_info(get_stack())
		if TweenInstance != null:
			TweenInstance.kill()

		TweenInstance = get_tree().create_tween()
		TweenInstance.finished.connect(on_tween_finished)
		TweenInstance.bind_node(node)

		#! This function includes the RoomBlock because its focusing on the PARENT node and not the node that is being animated from.
		if node.BlockCameraPosition != null:
			Global.Is_In_Animation = true
			if node is PropBlock:
				SignalManager.reset_player_camera.emit()
				var target_position = node.BlockCameraPosition.position
				TweenInstance.tween_property(Global.PlayerInstance, "position", target_position + node.position + node.BlockParent.position + Global.Game_Data_Instance.Current_Room.position , TweenDuration).from_current()
				var node_location: LocationBlock = search_for_parent(node)
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
				var target_position = node.BlockCameraPosition.position + node.position + Global.Game_Data_Instance.Current_Room.position
				TweenInstance.tween_property(Global.PlayerInstance, "position", target_position, TweenDuration).from_current()
				var target_rotation = node.BlockCameraPosition.rotation_degrees

				set_rotation_direction(target_rotation, node)
				TweenInstance.tween_property(Global.PlayerInstance, "rotation_degrees", target_rotation, TweenDuration)
				return

			if node is RoomBlock:
				TweenInstance.tween_property(Global.PlayerInstance, "position", node.BlockCameraPosition.position + node.position, TweenDuration)
				if node.PlayerRotation == true:
					#print_rich("Rounding to the nearest 90 degrees.")
					#Global.stack_info(get_stack())
					var target_rotation = 90 * round(Global.PlayerInstance.rotation_degrees.y / 90)
					TweenInstance.tween_property(Global.PlayerInstance, "rotation_degrees", Vector3(node.BlockCameraPosition.rotation.x, target_rotation, node.BlockCameraPosition.rotation.z), TweenDuration).from_current()
					return
				else:
					TweenInstance.tween_property(Global.PlayerInstance, "rotation_degrees", node.BlockCameraPosition.rotation_degrees, TweenDuration).from_current()
					return
			else:
				pass

	if node.BlockCameraPosition == null:
		#print_rich("Could not find camera position for " + str(_node) + ". Trying again.")
		#Global.stack_info(get_stack())
		for child in node.get_children():
			if child is CameraPosition:
				node.BlockCameraPosition = child
				move_to_camera_position(node, enable_position, enable_rotation)

func search_for_collider(node: Block) -> CollisionShape3D:
	if not node is RoomBlock:
		for child in node.get_children():
			if child is CollisionShape3D:
				return child
				#print_rich("Found collider for " + str(self.name) + ": " + str(child))
				#Global.stack_info(get_stack())
	return null

func disable_collider(node: Block):
	if node.BlockCollider != null:
		node.BlockCollider.set_disabled(true)
		return
	else:
		#print_rich(str(_node.name) + " does not have a collider to disable.")
		#Global.stack_info(get_stack())
		return

func enable_collider(node: Block):
	if node.BlockCollider != null:
		node.BlockCollider.set_disabled(false)
		return
	else:
		#print_rich(str(_node.name) + " does not have a collider to enable.")
		#Global.stack_info(get_stack())
		return

func search_for_locations(node: Node, enable: bool):
	if enable == true:
		for child in node.get_children():
			if child is LocationBlock:
				enable_collider(child)
				#print_rich("Found " + str(self.name) + "'s location block: " + str(child.name))
				#Global.stack_info(get_stack())
			else:
				search_for_locations(child, true)

	if enable == false:
		for child in node.get_children():
			if child is LocationBlock:
				disable_collider(child)
				#print_rich("Found " + str(self.name) + "'s location block: " + str(child.name))
				#Global.stack_info(get_stack())
			else:
				search_for_locations(child, false)

func search_for_props(node: Node, enable: bool):
	if enable == true:
		for child in node.get_children():
			if child is PropBlock:
				enable_collider(child)
				#print_rich("Found " + str(self.name) + "'s location block: " + str(child.name))
				#Global.stack_info(get_stack())
			else:
				search_for_props(child, true)

	if enable == false:
		for child in node.get_children():
			if child is PropBlock:
				disable_collider(child)
				#print_rich("Found " + str(self.name) + "'s location block: " + str(child.name))
				#Global.stack_info(get_stack())
			else:
				search_for_props(child, false)

func connect_activate_signal(node: Block):
	if node != null:
		if SignalManager.activate_block.is_connected(node.on_activate_block):
			return
		SignalManager.activate_block.connect(node.on_activate_block)
		return

func connect_deactivate_signal(node: Block):
	if node != null:
		if SignalManager.deactivate_block.is_connected(node.on_deactivate_block):
			return
		SignalManager.deactivate_block.connect(node.on_deactivate_block)
		return

func disconnect_activate_signal(node: Block):
	if node != null:
		if !SignalManager.activate_block.is_connected(node.on_activate_block):
			return
		SignalManager.activate_block.disconnect(node.on_activate_block)
		return

func disconnect_deactivate_signal(node: Block):
	if node != null:
		if !SignalManager.deactivate_block.is_connected(node.on_deactivate_block):
			return
		SignalManager.deactivate_block.disconnect(node.on_deactivate_block)
		return

func activate():
	#print_rich("Activating " + str(Global.Current_Block))
	#Global.stack_info(get_stack())
	move_to_camera_position(self, true, true)
	Global.Game_Data_Instance.Current_Block = self
	#print_rich(Global.Game_Data_Instance.Current_Block_Path)
	#Global.stack_info(get_stack())

	if self.PlayerRotation == true:
		Global.Is_Able_To_Turn = true
	else:
		Global.Is_Able_To_Turn = false
	if not self is RoomBlock:
		disable_collider(self)
	return

func on_activate_block(node: Block):
	node.activate()

func deactivate():
	if Global.Game_Data_Instance.Current_Event != "":
		SignalManager.stop_event.emit()

	if not self is RoomBlock:
		if self.BlockParent != null:
			SignalManager.activate_block.emit(self.BlockParent)
			return

		if BlockParent == null:
			push_error("Could not find " + str(self.name) + "'s parent")
			return
	return


func on_deactivate_block(node: Block):
	node.deactivate()

func set_rotation_ability():
	if Global.Game_Data_Instance:
		if Global.Game_Data_Instance.Current_Block == self:
			Global.Is_Able_To_Turn = self.PlayerRotation

func block_ready():
	set_rotation_ability()

	connect_activate_signal(self)
	connect_deactivate_signal(self)

	self.BlockParent = search_for_parent(self)
	self.BlockCameraPosition = search_for_camera_position(self)
	self.BlockCollider = search_for_collider(self)

	if self.BlockCollider != null:
		self.BlockCollider.disabled = true
	return

func manage_activation_signals():
	if Global.Game_Data_Instance.Current_Block == self:
		connect_activate_signal(self)
		connect_deactivate_signal(self)
		return

	if Global.Hovering_Block == self:
		connect_activate_signal(self)
		return

	disconnect_activate_signal(self)
	disconnect_deactivate_signal(self)

func _process(_delta):
	manage_activation_signals()

func _ready():
	block_ready()
