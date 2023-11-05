extends StaticBody3D

var MonsterPositionNumber: int = 0
var MonsterRoomNumber: int = 0
var MonsterRoom: RoomBlock

var WindowTimer: Timer = Timer.new()
const DefaultRoomPool = [1,3,4]
var RoomPool: Array = []

func get_random_number_from_window_pool():
	if RoomPool.size() == 0:
		return -1
	var index =  randi_range(0, RoomPool.size() - 1)
	return RoomPool[index]

func find_room_with_window():
	if RoomPool.size() > 0:
		var random_room_number = get_random_number_from_window_pool()
		#print_debug("Chosen room number: " + str(random_room_number))
		RoomPool.erase(random_room_number)
		#print_debug("New pool of possible rooms: " + str(room_pool))
		return random_room_number
	else:
		#push_error("No more numbers in the pool.")
		RoomPool.append_array(DefaultRoomPool)
		#print_debug("New pool of possible rooms: " + str(room_pool))
		var random_room_number = get_random_number_from_window_pool()
		#print_debug("Chosen room number: " + str(random_room_number))
		RoomPool.erase(random_room_number)
		#print_debug("New pool of possible rooms: " + str(room_pool))
		return random_room_number

func manage_window_timer():
	if WindowTimer == null:
		WindowTimer = Timer.new()
		self.add_child(WindowTimer)
		if !WindowTimer.timeout.is_connected(on_window_timer_timeout):
			WindowTimer.timeout.connect(on_window_timer_timeout)

func manage_monster_position():
	if not MonsterPositionNumber > 3:
		#print_debug("Monster position is " + str(MonsterPositionNumber))
		pass

	if MonsterPositionNumber == 0:
		self.set_visible(false)
		self.position = Vector3(0, -10, 0)
		MonsterPositionNumber += 1
		return

	elif MonsterPositionNumber == 1:
		#print_debug("Finding monster position #" + str(MonsterPositionNumber))
		self.set_visible(true)
		set_monster_position(Global.Monster_Data.Monster_Current_Room, 1)
		MonsterPositionNumber += 1
		return

	elif MonsterPositionNumber == 2:
		#print_debug("Finding monster position #" + str(MonsterPositionNumber))
		self.set_visible(true)
		set_monster_position(Global.Monster_Data.Monster_Current_Room, 2)
		MonsterPositionNumber += 1
		return

	elif MonsterPositionNumber == 3:
		#print_debug("Finding monster position #" + str(MonsterPositionNumber))
		self.set_visible(true)
		set_monster_position(Global.Monster_Data.Monster_Current_Room, 3)
		manage_window_timer()
		WindowTimer.one_shot = true
		WindowTimer.start(2)
		return
	else:
		push_error("Monster position is unkown")
		return

func manage_monster_room():
	if MonsterRoomNumber <= 0:
		move_monster_to_room()
		MonsterPositionNumber = 0
		return
	else:
		pass

func window_movement_management():
	manage_monster_room()
	manage_monster_position()

func set_monster_position(node, number):
	if MonsterRoom != null:
		for child in node.get_children():
			if child is MonsterPosition:
				if child.PositionNumber == number:
					if child.PositionRoom == MonsterRoom:
						#print_debug("Setting monsters position to " + str(child.name))
						SignalManager.set_monster_position.emit(child)
						return
					else:
						#push_warning("Monster position was not in the right room.")
						pass
				else:
					#push_warning("Monster position was not the right number.")
					pass
			if not child is MonsterPosition:
				set_monster_position(child, number)
				pass
	else:
		push_error("Could not find monster room.")
		return

func on_window_timer_timeout():
	find_window_node(MonsterRoom)

func on_random_tick():
	window_movement_management()

func on_monster_reset():
	MonsterPositionNumber = 0
	MonsterRoomNumber = 0
	MonsterRoom = null
	Global.Monster_Data.Monster_Current_Room = null
	WindowTimer.queue_free()
	window_movement_management()
	return

func move_monster_to_room():
	MonsterRoomNumber = find_room_with_window()
	# Game world
	SignalManager.find_monster_room.emit(Global.Loaded_Game_World, MonsterRoomNumber)
	#print_debug("Moving monster to room #" + str(MonsterRoomNumber))
	return

func find_window_node(node):
	for child in node.get_children():
		if child is WindowEvent:
			#print_debug("Using " + str(child.name) +" from " + str(child.BlockParent.name) + " as the window the monster is currently at.")
			SignalManager.open_window.emit(child)
			return

		elif not child is WindowEvent:
			find_window_node(child)

func _ready():
	self.set_visible(false)
	if Global.Monster_Data.Is_Monster_Active == true:
		RoomPool.append_array(DefaultRoomPool)
		SignalManager.random_tick.connect(on_random_tick)
		SignalManager.reset_monster.connect(on_monster_reset)
		self.add_child(WindowTimer)
		WindowTimer.timeout.connect(on_window_timer_timeout)
		manage_window_timer()

		self.position = Vector3(0, -10, 0)

func _process(_delta):
	if Global.Monster_Data.Is_Monster_Active == true:
		if Global.Monster_Data.Monster_Current_Room != null && Global.Monster_Data.Monster_Current_Room != self.MonsterRoom:
			self.MonsterRoom = Global.Monster_Data.Monster_Current_Room

		if MonsterPositionNumber <= 0:
			Global.Monster_Data.Monster_Current_Stage = 0
		else:
			Global.Monster_Data.Monster_Current_Stage = MonsterPositionNumber - 1
