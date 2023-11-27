extends StaticBody3D

const WaitTime: float = 1.5
var WindowTimer: Timer = Timer.new()

const DefaultRoomPool = [1,4,5]
var RoomPool: Array = []

var Room: RoomBlock = null
var LocalWindow: WindowBlock = null

var LocalCurrentStage: stage = stage.HIDDEN
enum stage {
	HIDDEN = 0,
	DISTANT = 1,
	MIDWAY = 2,
	NEAR = 3
}

func get_random_number() -> int:
	if RoomPool.size() == 0:
		return -1
	var index = randi_range(0, RoomPool.size() - 1)
	# Check if monster is already in this room
	if Global.Game_Data_Instance.Monster_Room_Number != null:
		if RoomPool[index] == Room.RoomNumber:
			index = randi_range(0, RoomPool.size() - 1)
			print_rich("Generated number %s is equal to %s. Cannot move monster to the room it is already in. Generating new number" %[index, Room.RoomNumber])
			Global.stack_info(get_stack())
			return RoomPool[index]
	return RoomPool[index]

func get_number_from_pool() -> int:
	if RoomPool.size() > 0:
		var random_room_number: int
		random_room_number = get_random_number()
		#print_rich("Chosen room number: %s" % [random_room_number])
		#Global.stack_info(get_stack())
		RoomPool.erase(random_room_number)
		#print_rich("New pool of possible rooms: %s" % [RoomPool])
		#Global.stack_info(get_stack())
		return random_room_number
	else:
		#push_warning("No more numbers in the pool.")
		RoomPool.append_array(DefaultRoomPool)
		#print_rich("New pool of possible rooms:  %s" % [RoomPool])
		#Global.stack_info(get_stack())
		var random_room_number: int
		random_room_number = get_random_number()

		#print_rich("Chosen room number: %s" % [RoomPool])
		#Global.stack_info(get_stack())
		RoomPool.erase(random_room_number)
		#print_rich("New pool of possible rooms: %s" % [RoomPool])
		#Global.stack_info(get_stack())
		return random_room_number

func find_room(node: Node, number: int):
	for child in node.get_children(true):
		#print_rich("Scanning %s" %[child])
		if child is RoomBlock && child.RoomNumber == number:
			Global.Game_Data_Instance.Monster_Current_Room = child.get_path()
			Room = child
			Global.Game_Data_Instance.Monster_Room_Number = Room.RoomNumber
			print_rich("Monster's room is the %s" %[str(child.name)])
			Global.stack_info(get_stack())
			SignalManager.monster_found_room.emit()
			return
		elif child is RoomBlock && child.RoomNumber != number:
			#printerr(str(child) + " is a room but not with the number " + str(number))
			#Global.stack_info(get_stack())
			pass
		elif not child is RoomBlock:
			find_room(child, number)
			pass

func set_monster_position(node, number):
	if Global.Game_Data_Instance.Monster_Current_Room != "":
		for child in node.get_children():
			if child is MonsterPosition:
				if child.PositionNumber == number:
					if child.PositionRoom == get_node(Global.Game_Data_Instance.Monster_Current_Room):
						#print_rich("Setting monsters position to %s"%[child.name])
						#Global.stack_info(get_stack())
						self.position = child.position + Room.position
						#print_rich("Monster's position: " + str(self.get_position) + " should equal the set position of " + str(child.position))
						#Global.stack_info(get_stack())
						self.rotation = child.rotation + Room.rotation
						#print_rich("Monster's rotation: " + str(self.get_rotation) + " should equal the set rotation of " + str(child.rotation))
						#Global.stack_info(get_stack())
						return
					pass
				pass
			set_monster_position(child, number)
			pass
	#printerr("Monster room returned null.")
	#Global.stack_info(get_stack())
	return

func on_timer_timeout():
	#print_rich("%s timed out. Opening %s" %[WindowTimer.name, LocalWindow.name])
	#Global.stack_info(get_stack())
	SignalManager.open_window.emit(LocalWindow)
	manage_window_timer()
	pass

func manage_window_timer():
	if WindowTimer != null:
		WindowTimer.queue_free()
	WindowTimer = Timer.new()
	WindowTimer.name = "WindowTimer"
	WindowTimer.timeout.connect(Callable(on_timer_timeout))
	self.add_child(WindowTimer)
	return

func on_monster_reset():
	#print_rich("Resetting monster.")
	#Global.stack_info(get_stack())
	Global.Game_Data_Instance.Monster_Current_Room = ""
	SignalManager.set_monster_room.emit(Global.Loaded_Game_World, get_number_from_pool())
	LocalWindow = null
	SignalManager.set_monster_stage.emit(0)

func find_window_node(node: Node):
	for child in node.get_children():
		#print_rich(child)
		#Global.stack_info(get_stack())
		if child is WindowBlock && child.BlockParent == Room:
			LocalWindow = child
			#print_rich("Found %s from %s" %[WindowNode.name, WindowNode.BlockParent.name])
			#Global.stack_info(get_stack())
			return
		find_window_node(child)
	return

func manage_stage():
	#print_rich("Setting monster stage to [b]%s[/b]" %[stage.keys()[Global.Game_Data_Instance.Monster_Current_Stage]])
	#Global.stack_info(get_stack())
	match Global.Game_Data_Instance.Monster_Current_Stage:
		stage.HIDDEN:
			self.set_visible(false)
			return

		stage.DISTANT:
			self.set_visible(true)
			set_monster_position(Room, 1)
			return

		stage.MIDWAY:
			self.set_visible(true)
			set_monster_position(Room, 2)
			return

		stage.NEAR:
			self.set_visible(true)
			set_monster_position(Room, 3)
			if Room == Global.Game_Data_Instance.Current_Room:
				WindowTimer.start(WaitTime)
			else:
				#print_rich("Occupying the %s" %[Room.name])
				#Global.stack_info(get_stack())
				Room.IsOccupied = true
			return

func set_stage(next: stage):
	if next > 3:
		return
	Global.Game_Data_Instance.Monster_Current_Stage = next
	LocalCurrentStage = next
	manage_stage()
	return

func manage_signals():
	SignalManager.set_monster_room.connect(Callable(find_room))
	SignalManager.set_monster_stage.connect(Callable(set_stage))
	SignalManager.reset_monster.connect(Callable(on_monster_reset))

func _process(_delta):
	if Room != null:
		Global.Game_Data_Instance.Monster_Current_Room = str(Room.get_path())
		if LocalWindow == null:
			find_window_node(Room)

	if Global.Game_Data_Instance.Monster_Current_Stage != LocalCurrentStage:
		set_stage(Global.Game_Data_Instance.Monster_Current_Stage)

	if Global.MonsterInstance == null:
		Global.MonsterInstance = self
		SignalManager.monster_loaded.emit()

	return

func _ready():
	self.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	self.add_child(WindowTimer)

	manage_window_timer()
	manage_signals()

	if Global.Game_Data_Instance.Monster_Current_Room != "":
		Room = get_node(Global.Game_Data_Instance.Monster_Current_Room)
		#print_rich("Monster is currently in %s" %[Room])
		#Global.stack_info(get_stack())
	set_stage(Global.Game_Data_Instance.Monster_Current_Stage)
#	manage_window_timer()
