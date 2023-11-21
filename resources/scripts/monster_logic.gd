extends StaticBody3D

const WaitTime: float = 1.5
var WindowTimer: Timer = Timer.new()

const DefaultRoomPool = [1,3,4]
var RoomPool: Array = []

var Room: RoomBlock = null
var WindowNode: WindowBlock = null

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
		if RoomPool[index] == Global.Game_Data_Instance.Monster_Room_Number:
			print_debug("Generated number %s is equal to %s. Cannot move monster to the room it is already in. Generating new number")
			index = randi_range(0, RoomPool.size() - 1)
			return RoomPool[index]
	return RoomPool[index]

func get_number_from_pool() -> int:
	if RoomPool.size() > 0:
		var random_room_number: int
		random_room_number = get_random_number()
		#print_debug("Chosen room number: %s" % [random_room_number])
		RoomPool.erase(random_room_number)
		#print_debug("New pool of possible rooms: %s" % [RoomPool])
		return random_room_number
	else:
		#push_warning("No more numbers in the pool.")
		RoomPool.append_array(DefaultRoomPool)
		#print_debug("New pool of possible rooms:  %s" % [RoomPool])
		var random_room_number: int
		random_room_number = get_random_number()

		#print_debug("Chosen room number: %s" % [RoomPool])
		RoomPool.erase(random_room_number)
		#print_debug("New pool of possible rooms: %s" % [RoomPool])
		return random_room_number

func find_room(node: Node, number: int):
	for child in node.get_children(true):
		#print_debug("Scanning %s" %[child])
		if child is RoomBlock && child.RoomNumber == number:
			Global.Game_Data_Instance.Monster_Current_Room = child.get_path()
			Room = child
			Global.Game_Data_Instance.Monster_Room_Number = Room.RoomNumber
			print_debug("Monster's room is the %s" %[str(child.name)])
			SignalManager.monster_found_room.emit()
			return
		elif child is RoomBlock && child.RoomNumber != number:
			#push_warning(str(child) + " is a room but not with the number " + str(number))
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
						#print_debug("Setting monsters position to %s"%[child.name])
						self.position = child.position + Room.position
						#print_debug("Monster's position: " + str(self.get_position) + " should equal the set position of " + str(child.position))
						self.rotation = child.rotation + Room.rotation
						#print_debug("Monster's rotation: " + str(self.get_rotation) + " should equal the set rotation of " + str(child.rotation))
						return
					pass
				pass
			set_monster_position(child, number)
			pass
	#push_error("Monster room returned null.")
	return

func on_timer_timeout():
	print_debug("%s timed out. Opening %s" %[WindowTimer.name, WindowNode])
	SignalManager.open_window.emit(WindowNode)
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
	print_debug("Resetting monster.")
	Global.Game_Data_Instance.Monster_Current_Room = ""
	SignalManager.set_monster_room.emit(Global.Loaded_Game_World, get_number_from_pool())
	WindowNode = null
	SignalManager.set_monster_stage.emit(0)

func find_window_node(node: Node):
	for child in node.get_children():
		#print_debug(child)
		if child is WindowBlock && child.BlockParent == Room:
			WindowNode = child
			#print_debug("Found %s from %s" %[WindowNode.name, WindowNode.BlockParent.name])
			return
		find_window_node(child)
	return

func manage_stage():
	match Global.Game_Data_Instance.Monster_Current_Stage:
		stage.HIDDEN:
			#print_debug("Setting monster stage to %s" % [Global.Game_Data_Instance.Monster_Current_Stage] )
			LocalCurrentStage = stage.HIDDEN
			self.set_visible(false)
			return

		stage.DISTANT:
			#print_debug("Setting monster stage to %s" % [Global.Game_Data_Instance.Monster_Current_Stage] )
			LocalCurrentStage = stage.DISTANT
			self.set_visible(true)
			set_monster_position(Room, 1)
			return

		stage.MIDWAY:
			#print_debug("Setting monster stage to %s" % [Global.Game_Data_Instance.Monster_Current_Stage] )
			LocalCurrentStage = stage.MIDWAY
			self.set_visible(true)
			set_monster_position(Room, 2)
			return

		stage.NEAR:
			#print_debug("Setting monster stage to %s" % [Global.Game_Data_Instance.Monster_Current_Stage])
			LocalCurrentStage = stage.NEAR
			self.set_visible(true)
			set_monster_position(Room, 3)
			if Room == Global.Game_Data_Instance.Current_Room:
				WindowTimer.start(WaitTime)
			else:
				print_debug("Occupying the %s" %[Room.name])
				Room.IsOccupied = true
			return

func set_stage(next: stage):
	if next > 3:
		return
	Global.Game_Data_Instance.Monster_Current_Stage = next
	print_debug("Setting monsters stage to %s" %[stage.keys()[next]])
	manage_stage()
	return

func manage_signals():
	SignalManager.set_monster_room.connect(Callable(find_room))
	SignalManager.set_monster_stage.connect(Callable(set_stage))
	SignalManager.reset_monster.connect(Callable(on_monster_reset))

func _process(_delta):
	if WindowNode == null && Room != null:
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
	set_stage(stage.HIDDEN)
#	manage_window_timer()
