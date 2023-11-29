extends Node3D
class_name Block

@export var PlayerRotation: bool
@export var BlockDialoguePath: JSON

const rotation_speed = 0.5
const TweenDuration: float = 0.5
var TweenInstance: Tween

@onready var BlockCameraPosition: CameraPosition = search_for_camera_position()
@onready var BlockCollider: CollisionShape3D = search_for_collider()
@onready var BlockParent: Block = search_for_parent(self)

var Locations: Array = []
var Interactables: Array = []

var IsActive: bool = false
var CanMove: bool = true

func search_for_camera_position() -> CameraPosition:
	for child in self.get_children():
		if child is CameraPosition:
			#print_rich("Found camera for %s" %[str(self.name)])
			#Global.stack_info(get_stack())
			return child
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

func search_for_collider() -> CollisionShape3D:
	for child in self.get_children():
		if child is CollisionShape3D:
			#print_rich("Found collider for " + str(node.name) + ": " + str(child))
			#Global.stack_info(get_stack())
			return child
	return null

func search_for_locations(node: Node):
	for child in node.get_children(true):
		if child is LocationBlock:
			if self.Locations.has(child):
				pass
			else:
				self.Locations.append(child)
		else:
			if child.get_parent() == self:
				search_for_locations(child)
			else:
				pass

func search_for_interactables(node: Node):
	for child in node.get_children(true):
		if child is Interactable:
			if self.Interactables.has(child):
				pass
			else:
				self.Interactables.append(child)
		else:
			for child2 in child.get_children(true):
				if child2 is Interactable:
					if self.Interactables.has(child2):
						pass
					else:
						self.Interactables.append(child2)

func on_tween_finished():
	#print_rich("Tween completed")
	#Global.stack_info(get_stack())
	Global.Is_In_Animation = false
	self.TweenInstance.kill()
	SignalManager.animation_finished.emit()

func set_rotation_direction(target_rotation: Vector3):
	if target_rotation.y > self.rotation_degrees.y + 45 or target_rotation.y < self.rotation_degrees.y -45:
		if target_rotation.y > 0 && Global.PlayerInstance.rotation_degrees.y < target_rotation.y:
			#print_rich("Rotating from %s clockwise." %[self.name])
			#Global.stack_info(get_stack())
			Global.PlayerInstance.rotation_degrees.y += 360
		elif target_rotation.y < 0 && Global.PlayerInstance.rotation_degrees.y > target_rotation.y:
			#print_rich("Rotating from %s anti-clockwise." %[self.name])
			#Global.stack_info(get_stack())
			Global.PlayerInstance.rotation_degrees.y -= 360

func move_to_camera_position():
	if self.BlockCameraPosition != null:
		#print_rich("Moving to " + str(node.name))
		#Global.stack_info(get_stack())
		if TweenInstance != null:
			TweenInstance.kill()

		TweenInstance = get_tree().create_tween()
		TweenInstance.finished.connect(on_tween_finished)
		TweenInstance.bind_node(self)

		#! This function includes the RoomBlock because its focusing on the PARENT node and not the node that is being animated from.
		if self.BlockCameraPosition != null:
			Global.Is_In_Animation = true
			if self is LocationBlock:
				SignalManager.reset_player_camera.emit()
				var target_position: Vector3
				if self.BlockParent is RoomBlock:
					target_position = self.BlockCameraPosition.position + self.position + self.BlockParent.position
				else:
					target_position = self.BlockCameraPosition.position + self.position + self.BlockParent.position + Global.Game_Data_Instance.Current_Room.position
				TweenInstance.tween_property(Global.PlayerInstance, "position", target_position, TweenDuration).from_current()
				var target_rotation: Vector3
				if self.BlockParent != null:
					target_rotation = self.BlockCameraPosition.rotation_degrees + self.BlockParent.rotation_degrees
				else:
					target_rotation = self.BlockCameraPosition.rotation_degrees

				set_rotation_direction(target_rotation)
				TweenInstance.tween_property(Global.PlayerInstance, "rotation_degrees", target_rotation, TweenDuration)
				return

			if self is RoomBlock:
				TweenInstance.tween_property(Global.PlayerInstance, "position", self.BlockCameraPosition.position + self.position, TweenDuration)
				if self.PlayerRotation == true:
					#print_rich("Rounding to the nearest 90 degrees.")
					#Global.stack_info(get_stack())
					var target_rotation = 90 * round(Global.PlayerInstance.rotation_degrees.y / 90)
					TweenInstance.tween_property(Global.PlayerInstance, "rotation_degrees", Vector3(self.BlockCameraPosition.rotation.x, target_rotation, self.BlockCameraPosition.rotation.z), TweenDuration).from_current()
					return
				else:
					TweenInstance.tween_property(Global.PlayerInstance, "rotation_degrees", self.BlockCameraPosition.rotation_degrees, TweenDuration).from_current()
					return
			else:
				pass

	if self.BlockCameraPosition == null:
		printerr("Could not find camera position for %s. Trying again." %[str(self.name)])
		Global.stack_info(get_stack())
		for child in self.get_children():
			if child is CameraPosition:
				self.BlockCameraPosition = child
				move_to_camera_position()
				return
		return

func disable_collider():
	if self.BlockCollider != null:
		if self.BlockCollider.is_disabled() == false:
			self.BlockCollider.set_disabled(true)
			return
	else:
		printerr("%s does not have a collider to disable." %[str(self.name)])
		Global.stack_info(get_stack())
		return

func enable_collider():
	if self.BlockCollider != null:
		if self.BlockCollider.is_disabled() == true:
			self.BlockCollider.set_disabled(false)
			return
	else:
		printerr("%s does not have a collider to enable." %[str(self.name)])
		Global.stack_info(get_stack())
		return

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
	#print_rich("Activating %s." %[str(self.name)])
	#Global.stack_info(get_stack())

	Global.Game_Data_Instance.Current_Block = self

	if self.Locations != []:
		for child in self.Locations:
			if child.BlockCollider != null:
				child.enable_collider()

	if self.Interactables != []:
		for child in self.Interactables:
			if child.InteractableCollider != null:
				if child.visible:
					child.enable_collider()

	if self.PlayerRotation == true:
		Global.Is_Able_To_Turn = true
	else:
		Global.Is_Able_To_Turn = false

	if self.BlockCollider != null:
		self.disable_collider()

	self.move_to_camera_position()
	return

func deactivate():
	print_rich("Deactivating %s." %[self.name])
	Global.stack_info(get_stack())

	if Global.Game_Data_Instance.Current_Event != "":
		SignalManager.stop_event.emit()

	if self.Locations != []:
		for child in self.Locations:
			if child.BlockCollider != null:
				child.disable_collider()

	if self.Interactables != []:
		for child in self.Interactables:
			if child.InteractableCollider != null:
				child.disable_collider()

	if self.BlockParent == null:
		printerr("Could not find %s's parent" %[str(self.name)])
		Global.stack_info(get_stack())
		return

	SignalManager.activate_block.emit(self.BlockParent)
	return

func on_activate_block(node: Block):
	node.activate()

func on_deactivate_block(node: Block):
	node.deactivate()

func set_rotation_ability():
	if Global.Game_Data_Instance:
		if Global.Game_Data_Instance.Current_Block == self:
			Global.Is_Able_To_Turn = self.PlayerRotation

func block_ready():
	self.set_rotation_ability()

	self.connect_activate_signal(self)
	self.connect_deactivate_signal(self)
	self.disable_collider()
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
