extends LocationBlock
class_name DoorEvent

@export var Is_Door_Open: bool
@export var ConnectedRoomOne: int
@export var ConnectedRoomTwo: int

var DoorTweenInstance: Tween

var PivotPoint: Node3D
var DoorHandle: Node3D
var Is_Enabled: bool = false

var PivotPointOriginalYRotation: float

const door_opening_time: float = 1.5
const door_opening_degrees: float = 90
var door_closing_time: float

const handle_turning_time: float = 0.5
const handle_turning_degrees: float = 25

func find_pivot_point(_node: Node3D):
	for child in _node.get_children():
		if child.name == "PivotPoint":
			return child
		elif child.name != "PivotPoint":
			pass

func find_door_handle(_node: Node3D):
	for child in _node.get_children():
		if child.name == "DoorHandle":
			return child
		else:
			find_door_handle(child)

func on_open_door():
	if self.Is_Enabled == true:
		if DoorTweenInstance:
			DoorTweenInstance.kill()

		DoorTweenInstance = get_tree().create_tween().chain()
		DoorTweenInstance.bind_node(self)

		if Is_Door_Open == true:
			return

		if Is_Door_Open == false:
			if self.DoorHandle != null:
				DoorTweenInstance.tween_property(self.DoorHandle, "rotation_degrees:z", handle_turning_degrees - self.DoorHandle.rotation_degrees.z, handle_turning_time).from_current()
			elif self.DoorHandle == null:
				print_debug("Door handle returned null. Could not animate.")
				pass

			if self.PivotPoint != null:
				DoorTweenInstance.tween_property(self.PivotPoint, "rotation_degrees:y", self.PivotPoint.rotation_degrees.y + door_opening_degrees - self.rotation_degrees.y, door_opening_time).from_current()
				return
			elif self.PivotPoint == null:
				print_debug("Pivot point returned null. Could not animate.")
				return

func on_close_door():
	if self.Is_Enabled == true:
		if DoorTweenInstance:
			DoorTweenInstance.kill()

		DoorTweenInstance = get_tree().create_tween().chain()
		DoorTweenInstance.bind_node(self)

		if self.PivotPoint != null:
			DoorTweenInstance.tween_property(self.PivotPoint, "rotation_degrees:y", PivotPointOriginalYRotation, door_closing_time).from_current()
		elif self.PivotPoint == null:
			print_debug("Pivot point returned null. Could not animate.")
			pass

		if self.DoorHandle != null:
			DoorTweenInstance.tween_property(self.DoorHandle, "rotation_degrees:z", 0, 0.5).from_current()
			return
		elif self.DoorHandle == null:
			print_debug("Door handle returned null. Could not animate.")
			return

func find_current_room():
	# If the current room number is one of the two options move to the other one.
	if Global.Current_Room.RoomNumber == ConnectedRoomOne:
		#print_debug("Opposite room is #" + str(ConnectedRoomTwo))
		return ConnectedRoomTwo
	elif Global.Current_Room.RoomNumber == ConnectedRoomTwo:
		#print_debug("Opposite room is #" + str(ConnectedRoomOne))
		return ConnectedRoomOne
	else:
		print_debug("Could not find room number out of either ConnectedRoomOne or ConnectedRoomTwo.")

func start_event():
	if Global.Is_In_Animation == false:
		# Game world
		SignalManager.enable_other_side_of_door.emit(find_current_room())
		Global.Current_Event = "door"
		# Self
		if SignalManager.open_door.is_connected(on_open_door):
			pass
		elif !SignalManager.open_door.is_connected(on_open_door):
			# Self
			SignalManager.open_door.connect(on_open_door)

		# Self
		if SignalManager.close_door.is_connected(on_close_door):
			pass
		elif !SignalManager.close_door.is_connected(on_close_door):
			# Self
			SignalManager.close_door.connect(on_close_door)

func on_stop_event():
	#print_debug("Stopping door event.")
	# Game world
	if self.Is_Door_Open == true:
		SignalManager.close_door.emit()
	Global.Current_Event = ""
	SignalManager.disable_other_side_of_door.emit(find_current_room())

func manage_signals():
	if Global.Current_Active_Block == self:
		# Self
		if !SignalManager.stop_event.is_connected(on_stop_event):
			SignalManager.stop_event.connect(on_stop_event)

		# Self
		if !SignalManager.activate_block.is_connected(on_activate_block):
			SignalManager.activate_block.connect(on_activate_block)

		# Self
		if !SignalManager.deactivate_block.is_connected(on_deactivate_block):
			SignalManager.deactivate_block.connect(on_deactivate_block)
	else:
		# Self
		if SignalManager.stop_event.is_connected(on_stop_event):
			SignalManager.stop_event.disconnect(on_stop_event)

		# Self
		if SignalManager.activate_block.is_connected(on_activate_block):
			SignalManager.activate_block.disconnect(on_activate_block)

		# Self
		if SignalManager.deactivate_block.is_connected(on_deactivate_block):
			SignalManager.deactivate_block.disconnect(on_deactivate_block)

		if Global.Hovering_Block == self:
			# Self
			if !SignalManager.activate_block.is_connected(on_activate_block):
				SignalManager.activate_block.connect(on_activate_block)

func manage_global_door_variable():
	if self.Is_Enabled == true:
		if self.PivotPoint != null:
			if self.PivotPoint.rotation_degrees.y >= PivotPointOriginalYRotation + 90:
				#print_debug("Door is open.")
				self.Is_Door_Open = true
				Global.Is_Door_Opened = true
			elif self.PivotPoint.rotation_degrees.y < PivotPointOriginalYRotation + 90:
				#print_debug("Door is closed.")
				self.Is_Door_Open = false
				Global.Is_Door_Opened = false
		elif self.PivotPoint == null:
			#print_debug("Pivot point returned null.")
			pass

func _ready():
	search_for_parent_block(self)
	search_for_camera_position(self)
	search_for_collider(self)
	self.PivotPoint = find_pivot_point(self)
	self.DoorHandle = find_door_handle(PivotPoint)

	PivotPointOriginalYRotation = self.PivotPoint.rotation_degrees.y

	if BlockCollider != null:
		BlockCollider.set_disabled(true)
	elif BlockCollider == null:
		print_debug(str(self.name) + " does not have a collider.")

func _process(_delta):
	set_rotation_ability()
	manage_signals()
	manage_global_door_variable()

	if DoorTweenInstance != null:
		door_closing_time = DoorTweenInstance.get_total_elapsed_time()

	if Global.Current_Active_Block == self:
		self.Is_Enabled = true
		if Global.Current_Event != "door":
			search_for_props(self, true)
			start_event()
	elif Global.Current_Active_Block != self:
		self.Is_Enabled = false
		search_for_props(self, false)

	if BlockParent == Global.Current_Room:
		#print_debug(str(Global.Current_Room) + " has " + str(self.name) + " as a child.")
		self.set_visible(true)
	elif BlockParent != Global.Current_Room:
		self.set_visible(false)
