extends StaticBody3D

var WindowTimer: Timer = Timer.new()
var CurrentRoom: RoomBlock
var CurrentRoomNumber: int
var CurrentStage

const DefaultRoomPool = [1,3,4]
var RoomPool: Array = []

func manage_monster():
	if Global.Game_Data_Instance.Monster_Room_Number == 0:
		SignalManager.find_monster_room.emit(Global.Loaded_Game_World, find_room_with_window())
		return
	else:
		manage_monster_position()
		return

func get_random_number_from_window_pool() -> int:
	if RoomPool.size() == 0:
		return -1
	var index = randi_range(0, RoomPool.size() - 1)
	if Global.Game_Data_Instance.Monster_Room_Number != null:
		if RoomPool[index] == Global.Game_Data_Instance.Monster_Room_Number:
			print_debug("Generated number %s is equal to %s. Generating new number")
			index = randi_range(0, RoomPool.size() - 1)
			return RoomPool[index]
	return RoomPool[index]


func find_room_with_window() -> int:
	if RoomPool.size() > 0:
		var random_room_number: int = get_random_number_from_window_pool()
		#print_debug("Chosen room number: %s" % [random_room_number])
		RoomPool.erase(random_room_number)
		#print_debug("New pool of possible rooms: %s" % [RoomPool])
		return random_room_number
	else:
		#push_warning("No more numbers in the pool.")
		RoomPool.append_array(DefaultRoomPool)
		#print_debug("New pool of possible rooms:  %s" % [RoomPool])
		var random_room_number: int
		random_room_number = get_random_number_from_window_pool()

		#print_debug("Chosen room number: %s" % [RoomPool])
		RoomPool.erase(random_room_number)
		#print_debug("New pool of possible rooms: %s" % [RoomPool])
		return random_room_number

func find_monster_room(node, number):
	for child in node.get_children(true):
		#print_debug("Scanning %s"%[child])
		if child is RoomBlock && child.RoomNumber == number:
			Global.Game_Data_Instance.Monster_Current_Room = child
			Global.Game_Data_Instance.Monster_Room_Number = child.RoomNumber
			print_debug("Monster is in the " + str(child.name))
			SignalManager.monster_found_room.emit()
			return
		elif child is RoomBlock && child.RoomNumber != number:
			#push_warning(str(child) + " is a room but not with the number " + str(number))
			pass
		elif not child is RoomBlock:
			find_monster_room(child, number)
			pass

func manage_monster_position():
	if Global.Game_Data_Instance.Monster_Current_Stage == 0:
		Global.Game_Data_Instance.Monster_Current_Stage += 1
		print_debug("Setting monster position to #%s" % [Global.Game_Data_Instance.Monster_Current_Stage] )
		self.set_visible(false)
		self.position = Vector3(0, -10, 0)
		return

	if Global.Game_Data_Instance.Monster_Current_Stage == 1:
		Global.Game_Data_Instance.Monster_Current_Stage += 1
		print_debug("Setting monster position to #%s" % [Global.Game_Data_Instance.Monster_Current_Stage] )
		self.set_visible(true)
		set_monster_position(Global.Game_Data_Instance.Monster_Current_Room, 1)
		return

	if Global.Game_Data_Instance.Monster_Current_Stage == 2:
		Global.Game_Data_Instance.Monster_Current_Stage += 1
		print_debug("Setting monster position #%s" % [Global.Game_Data_Instance.Monster_Current_Stage] )
		self.set_visible(true)
		set_monster_position(Global.Game_Data_Instance.Monster_Current_Room, 2)
		return

	if Global.Game_Data_Instance.Monster_Current_Stage == 3:
		Global.Game_Data_Instance.Monster_Current_Stage += 1
		print_debug("Setting monster position #%s" % [Global.Game_Data_Instance.Monster_Current_Stage] )
		self.set_visible(true)
		set_monster_position(Global.Game_Data_Instance.Monster_Current_Room, 3)
		manage_window_timer()
		WindowTimer.one_shot = true
		WindowTimer.start(2)
		await WindowTimer.timeout
		find_window_node(Global.Game_Data_Instance.Monster_Current_Room)
		WindowTimer.queue_free()
		return

	if Global.Game_Data_Instance.Monster_Current_Stage > 3:
		pass

func set_monster_position(node, number):
	if Global.Game_Data_Instance.Monster_Current_Room != null:
		for child in node.get_children():
			if child is MonsterPosition:
				if child.PositionNumber == number:
					if child.PositionRoom == Global.Game_Data_Instance.Monster_Current_Room:
						#print_debug("Setting monsters position to %s"%[child.name])
						self.position = child.position + Global.Game_Data_Instance.Monster_Current_Room.position
						#print_debug("Monster's position: " + str(self.get_position) + " should equal the set position of " + str(child.position))
						self.rotation = child.rotation + Global.Game_Data_Instance.Monster_Current_Room.rotation
						#print_debug("Monster's rotation: " + str(self.get_rotation) + " should equal the set rotation of " + str(child.rotation))
						return
					pass
				pass
			set_monster_position(child, number)
			pass
	#push_error("Monster room returned null.")
	return

func manage_window_timer():
	if WindowTimer != null:
		WindowTimer.queue_free()
	WindowTimer = Timer.new()
	self.add_child(WindowTimer)
	return

func on_monster_reset():
	print_debug("Resetting monster.")
	Global.Game_Data_Instance.Monster_Current_Stage = 0
	Global.Game_Data_Instance.Monster_Room_Number = find_room_with_window()
	Global.Game_Data_Instance.Monster_Current_Room = null
	SignalManager.find_monster_room.emit(Global.Loaded_Game_World, Global.Game_Data_Instance.Monster_Room_Number)
	manage_monster_position()

func find_window_node(node):
	for child in node.get_children():
		if child is WindowEvent:
			print_debug("Opening %s from %s" %[child.name, child.BlockParent.name])
			SignalManager.open_window.emit(child)
			return
		elif not child is WindowEvent:
			find_window_node(child)

func manage_signals():
	SignalManager.find_monster_room.connect(Callable(find_monster_room))
	SignalManager.set_monster_position.connect(Callable(manage_monster_position))
	SignalManager.reset_monster.connect(Callable(on_monster_reset))
	SignalManager.game_over.connect(Callable(on_monster_reset))

func _process(_delta):
	if Global.MonsterInstance == null:
		SignalManager.monster_loaded.emit()
		Global.MonsterInstance = self

func _ready():
	manage_signals()
	self.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	self.position = Vector3(0, -10, 0)
	self.add_child(WindowTimer)
	manage_window_timer()
	RoomPool.append_array(DefaultRoomPool)
	SignalManager.find_monster_room.emit(Global.Loaded_Game_World, find_room_with_window())
