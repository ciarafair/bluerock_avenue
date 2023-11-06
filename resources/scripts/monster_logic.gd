extends StaticBody3D

var WindowTimer: Timer = Timer.new()
const DefaultRoomPool = [1,3]
var RoomPool: Array = []

func on_random_tick():
	manage_monster_room()

func manage_monster_room():
	if Global.Game_Data.Monster_Room_Number == 0:
		move_monster_to_room()
		return
	else:
		manage_monster_position()
		return


func find_room_with_window():
	if RoomPool.size() > 0:
		var random_room_number = get_random_number_from_window_pool()
		#print_debug("Chosen room number: %s" % [random_room_number])
		RoomPool.erase(random_room_number)
		#print_debug("New pool of possible rooms: %s" % [RoomPool])
		return random_room_number
	else:
		#push_warning("No more numbers in the pool.")
		RoomPool.append_array(DefaultRoomPool)
		#print_debug("New pool of possible rooms:  %s" % [RoomPool])
		var random_room_number = get_random_number_from_window_pool()
		#print_debug("Chosen room number: %s" % [RoomPool])
		RoomPool.erase(random_room_number)
		#print_debug("New pool of possible rooms: %s" % [RoomPool])
		return random_room_number

func move_monster_to_room():
	Global.Game_Data.Monster_Room_Number = find_room_with_window()
	find_monster_room(Global.Loaded_Game_World, Global.Game_Data.Monster_Room_Number)
	return

func find_monster_room(node, number):
	for child in node.get_children(true):
		#print_debug("Scanning %s"%[child])
		if child is RoomBlock && child.RoomNumber == number:
			Global.Game_Data.Monster_Current_Room = child
			print_debug("Monster is in the " + str(child.name))
			manage_monster_position()
			return
		elif child is RoomBlock && child.RoomNumber != number:
			#push_warning(str(child) + " is a room but not with the number " + str(number))
			pass
		elif not child is RoomBlock:
			find_monster_room(child, number)
			pass

func manage_monster_position():
	if Global.Game_Data.Monster_Current_Stage == 0:
		self.set_visible(false)
		self.position = Vector3(0, -10, 0)
		Global.Game_Data.Monster_Current_Stage += 1
		return

	if Global.Game_Data.Monster_Current_Stage == 1:
		print_debug("Setting monster position to #%s" % [Global.Game_Data.Monster_Current_Stage] )
		self.set_visible(true)
		set_monster_position(Global.Game_Data.Monster_Current_Room, 1)
		Global.Game_Data.Monster_Current_Stage += 1
		return

	if Global.Game_Data.Monster_Current_Stage == 2:
		print_debug("Setting monster position #%s" % [Global.Game_Data.Monster_Current_Stage] )
		self.set_visible(true)
		set_monster_position(Global.Game_Data.Monster_Current_Room, 2)
		Global.Game_Data.Monster_Current_Stage += 1
		return

	if Global.Game_Data.Monster_Current_Stage == 3:
		#print_debug("Setting monster position #%s" % [Global.Game_Data.Monster_Current_Stage] )
		self.set_visible(true)
		set_monster_position(Global.Game_Data.Monster_Current_Room, 3)
		manage_window_timer()
		WindowTimer.one_shot = true
		WindowTimer.start(2)
		Global.Game_Data.Monster_Current_Stage += 1
		return

	if Global.Game_Data.Monster_Current_Stage > 3:
		pass

func set_monster_position(node, number):
	if Global.Game_Data.Monster_Current_Room != null:
		for child in node.get_children():
			if child is MonsterPosition:
				if child.PositionNumber == number:
					if child.PositionRoom == Global.Game_Data.Monster_Current_Room:
						#print_debug("Setting monsters position to %s"%[child.name])
						self.position = child.position + Global.Game_Data.Monster_Current_Room.position
						#print_debug("Monster's position: " + str(self.get_position) + " should equal the set position of " + str(child.position))
						self.rotation = child.rotation + Global.Game_Data.Monster_Current_Room.rotation
						#print_debug("Monster's rotation: " + str(self.get_rotation) + " should equal the set rotation of " + str(child.rotation))
						return
					else:
						#push_warning("Monster position %s was not in the right room."%[child.name])
						pass
				else:
					#push_warning("Monster position %s was not the right number."%[child.PositionNumber])
					pass
			if not child is MonsterPosition:
				set_monster_position(child, number)
				pass
	else:
		#push_error("Monster room returned null.")
		return

func get_random_number_from_window_pool():
	if RoomPool.size() == 0:
		return -1
	var index =  randi_range(0, RoomPool.size() - 1)
	return RoomPool[index]

func manage_window_timer():
	if WindowTimer == null:
		WindowTimer = Timer.new()
		self.add_child(WindowTimer)
		if !WindowTimer.timeout.is_connected(on_window_timer_timeout):
			WindowTimer.timeout.connect(on_window_timer_timeout)

func on_window_timer_timeout():
	find_window_node(Global.Game_Data.Monster_Current_Room)

func on_monster_reset():
	Global.Game_Data.Monster_Current_Stage = 0
	Global.Game_Data.Monster_Room_Number = 0
	Global.Game_Data.Monster_Current_Room = null
	WindowTimer.queue_free()
	manage_monster_room()
	return

func find_window_node(node):
	for child in node.get_children():
		if child is WindowEvent:
			print_debug("Using " + str(child.name) +" from " + str(child.BlockParent.name) + " as the window the monster is currently at.")
			SignalManager.open_window.emit(child)
			return
		elif not child is WindowEvent:
			find_window_node(child)

func _ready():
	if Global.Game_Data.Is_Monster_Active == true:
		RoomPool.append_array(DefaultRoomPool)
		SignalManager.random_tick.connect(on_random_tick)
		SignalManager.reset_monster.connect(on_monster_reset)
		self.add_child(WindowTimer)
		WindowTimer.timeout.connect(on_window_timer_timeout)
		manage_window_timer()

		self.position = Vector3(0, -10, 0)
	else:
		self.set_visible(false)

