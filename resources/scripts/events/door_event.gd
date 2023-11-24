extends LocationBlock
class_name DoorBlock

@export var ConnectedRoomOne: int
@export var ConnectedRoomTwo: int

enum state {
	OPENED = 0,
	CLOSED = 1
}

var CurrentStatus: state = state.CLOSED
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

func find_pivot_point(node: Node3D):
	for child in node.get_children():
		if child.name == "PivotPoint":
			return child
		elif child.name != "PivotPoint":
			pass

func find_door_handle(node: Node3D):
	for child in node.get_children():
		if child.name == "DoorHandle":
			return child
		else:
			find_door_handle(child)

func set_door_state(next: state):
	self.CurrentStatus = next
	#print_rich("Changing door state to %s" %[CurrentStatus])
	#Global.stack_info(get_stack())
	match CurrentStatus:
		self.state.OPENED:
			open_door()
			return

		self.state.CLOSED:
			close_door()
			return

func twist_doorhandle():
	if self.DoorHandle != null:
		self.DoorTweenInstance.tween_property(self.DoorHandle, "rotation_degrees:z", handle_turning_degrees - self.DoorHandle.rotation_degrees.z, handle_turning_time).from_current()
		pass

	elif self.DoorHandle == null:
		printerr("Door handle returned null. Could not animate.")
		Global.stack_info(get_stack())
		pass

func reset_doorhandle():
	if self.DoorHandle != null:
		self.DoorTweenInstance.tween_property(self.DoorHandle, "rotation_degrees:z", 0, handle_turning_time).from_current()
		return

	elif self.DoorHandle == null:
		printerr("Door handle returned null. Could not animate.")
		Global.stack_info(get_stack())
		return

func open_door():
	SignalManager.enable_other_side_of_door.emit(Global.Loaded_Game_World, find_other_room())
	Global.Is_Door_Open = true
	if self.Is_Enabled == true:
		if self.DoorTweenInstance:
			self.DoorTweenInstance.kill()

		self.DoorTweenInstance = get_tree().create_tween().chain()
		self.DoorTweenInstance.bind_node(self)

		if self.PivotPoint != null:
			twist_doorhandle()
			self.DoorTweenInstance.tween_property(self.PivotPoint, "rotation_degrees:y", self.PivotPoint.rotation_degrees.y + door_opening_degrees - self.rotation_degrees.y, door_opening_time).from_current().finished.connect(Callable(on_door_opened))
			return

		elif self.PivotPoint == null:
			printerr("Pivot point returned null. Could not animate.")
			Global.stack_info(get_stack())
			return

func on_door_opened():
	await self.DoorTweenInstance.finished
	pass

func close_door():
	if self.Is_Enabled == true:
		if self.DoorTweenInstance:
			self.DoorTweenInstance.kill()

		self.DoorTweenInstance = get_tree().create_tween()
		self.DoorTweenInstance.bind_node(self)

		if self.PivotPoint != null:
			self.DoorTweenInstance.tween_property(self.PivotPoint, "rotation_degrees:y", PivotPointOriginalYRotation, door_closing_time).from_current().finished.connect(Callable(on_door_closed))
			reset_doorhandle()
			pass

		elif self.PivotPoint == null:
			printerr("Pivot point returned null. Could not animate.")
			Global.stack_info(get_stack())
			pass

func find_room_by_number(node: Node, number: int):
	for child in node.get_children(true):
		if child is RoomBlock && child.RoomNumber == number:
			#print_rich("Using %s as room to check if monster is inside." %[child])
			return child
		elif not child is RoomBlock:
			#push_warning(str(child.name) + " is a room, but does not have the ID of " + str(number) + ". Not enabling.")
			#print_rich("Using %s as node to find room." %[child])
			return find_room_by_number(child, number)

func check_if_player_is_listening_to_door():
	var boolian: bool = false
	if Global.Game_Data_Instance.Current_Block is DoorBlock:
		if boolian == false:
			var room: RoomBlock = find_room_by_number(Global.Loaded_Game_World, Global.Game_Data_Instance.Current_Block.find_other_room())
			#print_rich("Player is listening to door.")
			if room != null:
				if room.IsOccupied == true:
					print_rich("Room #%s is [color=#EE6055]occupied[/color]," %[Global.Game_Data_Instance.Current_Block.find_other_room()])
					Global.stack_info(get_stack())
					boolian = true
					return
				print_rich("Room #%s is [color=#CDE7B0]not occupied[/color]." %[Global.Game_Data_Instance.Current_Block.find_other_room()])
				Global.stack_info(get_stack())
				boolian = true
				return
			room = find_room_by_number(Global.Loaded_Game_World, Global.Game_Data_Instance.Current_Block.find_other_room())
			return

func on_door_closed():
	await self.DoorTweenInstance.finished
	Global.Is_Door_Open = false
	SignalManager.disable_other_side_of_door.emit(Global.Loaded_Game_World, find_other_room())

func on_toggle_door():
	if Global.Game_Data_Instance.Current_Block == self:
		if self.CurrentStatus == self.state.CLOSED:
			set_door_state(self.state.OPENED)
			return

		if self.CurrentStatus == self.state.OPENED:
			set_door_state(self.state.CLOSED)
			return

func find_other_room():
	# If the current room number is one of the two options move to the other one.
	if Global.Game_Data_Instance.Current_Room.RoomNumber == ConnectedRoomOne:
		#print_rich("Opposite room is #" + str(ConnectedRoomTwo))
		#Global.stack_info(get_stack())
		return ConnectedRoomTwo
	elif Global.Game_Data_Instance.Current_Room.RoomNumber == ConnectedRoomTwo:
		#print_rich("Opposite room is #" + str(ConnectedRoomOne))
		#Global.stack_info(get_stack())
		return ConnectedRoomOne
	elif Global.Game_Data_Instance.Current_Room.RoomNumber != ConnectedRoomOne and Global.Game_Data_Instance.Current_Room.RoomNumber != ConnectedRoomTwo:
		printerr("Could not find room number out of either %s or %s." % [ConnectedRoomOne, ConnectedRoomTwo])
		Global.stack_info(get_stack())

func start_event():
	self.PivotPoint = find_pivot_point(self)
	self.DoorHandle = find_door_handle(self.PivotPoint)

	self.PivotPointOriginalYRotation = self.PivotPoint.rotation_degrees.y

	if Global.Is_In_Animation == false:
		# Signal in game_world.gd
		SignalManager.enable_other_side_of_door.emit(Global.Loaded_Game_World, find_other_room())
		Global.Game_Data_Instance.Current_Event = "door"

		if SignalManager.open_door.is_connected(Callable(set_door_state)):
			pass
		elif !SignalManager.open_door.is_connected(Callable(set_door_state)):
			SignalManager.open_door.connect(Callable(set_door_state).bind(self.state.OPENED))

		if SignalManager.close_door.is_connected(Callable(set_door_state)):
			pass
		elif !SignalManager.close_door.is_connected(Callable(set_door_state)):
			SignalManager.close_door.connect(Callable(set_door_state).bind(self.state.CLOSED))

func on_stop_event():
	#print_rich("Stopping door event.")
	#Global.stack_info(get_stack())
	SignalManager.close_door.emit()
	Global.Game_Data_Instance.Current_Event = ""

func manage_signals():
	if Global.Game_Data_Instance.Current_Block == self:
		if !SignalManager.toggle_door.is_connected(Callable(on_toggle_door)):
			SignalManager.toggle_door.connect(Callable(on_toggle_door))

		if !SignalManager.stop_event.is_connected(Callable(on_stop_event)):
			SignalManager.stop_event.connect(Callable(on_stop_event))

		if !SignalManager.activate_block.is_connected(Callable(on_activate_block)):
			SignalManager.activate_block.connect(Callable(on_activate_block))

		if !SignalManager.deactivate_block.is_connected(Callable(on_deactivate_block)):
			SignalManager.deactivate_block.connect(Callable(on_deactivate_block))
	else:
		if !SignalManager.toggle_door.is_connected(Callable(on_toggle_door)):
			SignalManager.toggle_door.connect(Callable(on_toggle_door))

		if SignalManager.stop_event.is_connected(Callable(on_stop_event)):
			SignalManager.stop_event.disconnect(Callable(on_stop_event))

		if SignalManager.activate_block.is_connected(Callable(on_activate_block)):
			SignalManager.activate_block.disconnect(Callable(on_activate_block))

		if SignalManager.deactivate_block.is_connected(Callable(on_deactivate_block)):
			SignalManager.deactivate_block.disconnect(Callable(on_deactivate_block))

		if Global.Hovering_Block == self:
			if !SignalManager.activate_block.is_connected(Callable(on_activate_block)):
				SignalManager.activate_block.connect(Callable(on_activate_block))

func move_to_other_room():
	if Global.Game_Data_Instance.Current_Block.CurrentStatus == 0:
		if Global.Game_Data_Instance.Current_Room.RoomNumber == self.ConnectedRoomOne:
			Global.Game_Data_Instance.Current_Room.set_visible(false)
			Global.Game_Data_Instance.Current_Event = ""
			print_rich("Moving to room #" + str(Global.Game_Data_Instance.Current_Block.ConnectedRoomTwo))
			Global.stack_info(get_stack())
			SignalManager.move_to_room.emit(Global.Loaded_Game_World, self.ConnectedRoomTwo)
			SignalManager.stop_event.emit()
			return
		elif Global.Game_Data_Instance.Current_Room.RoomNumber == self.ConnectedRoomTwo:
			Global.Game_Data_Instance.Current_Room.set_visible(false)
			Global.Game_Data_Instance.Current_Event = ""
			print_rich("Moving to room #" + str(Global.Game_Data_Instance.Current_Block.ConnectedRoomOne))
			Global.stack_info(get_stack())
			SignalManager.move_to_room.emit(Global.Loaded_Game_World, self.ConnectedRoomOne)
			SignalManager.stop_event.emit()
			return
	return

func _process(_delta):
	set_rotation_ability()
	manage_activation_signals()
	manage_signals()
	manage_current_block()

	if self.DoorTweenInstance != null:
		door_closing_time = self.DoorTweenInstance.get_total_elapsed_time()

	if Global.Game_Data_Instance.Current_Block == self:
		self.Is_Enabled = true
		if Global.Game_Data_Instance.Current_Event != "door":
			start_event()
	elif Global.Game_Data_Instance.Current_Block != self:
		self.Is_Enabled = false

	if self.BlockParent == Global.Game_Data_Instance.Current_Room:
		#print_rich(str(Global.Current_Room) + " has " + str(self.name) + " as a child.")
		self.set_visible(true)
	elif self.BlockParent != Global.Game_Data_Instance.Current_Room:
		self.set_visible(false)
