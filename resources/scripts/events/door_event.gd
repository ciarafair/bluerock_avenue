extends LocationBlock

@onready var AnimationPlayerInstance: AnimationPlayer = $AnimationPlayer
@export var Is_Door_Open: bool
@export var ConnectedRoomOne: int
@export var ConnectedRoomTwo: int

func on_open_door():
	if Is_Door_Open == true:
		return

	if Is_Door_Open == false:
		AnimationPlayerInstance.play("peek_door")

func on_close_door():
	AnimationPlayerInstance.play_backwards("peek_door")

func find_current_room():
	# If the current room number is one of the two options move to the other one.
	if Global.Current_Room.RoomNumber == ConnectedRoomOne:
		print_debug("Opposite room #" + str(ConnectedRoomTwo))
		return ConnectedRoomTwo
	elif Global.Current_Room.RoomNumber == ConnectedRoomTwo:
		print_debug("Opposite room #" + str(ConnectedRoomOne))
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
		else:
			# Self
			SignalManager.open_door.connect(on_open_door)

		# Self
		if SignalManager.close_door.is_connected(on_close_door):
			pass
		else:
			# Self
			SignalManager.close_door.connect(on_close_door)

func on_stop_event():
	print_debug("Stopping door event.")
	# Game world
	SignalManager.disable_other_side_of_door.emit(find_current_room())
	Global.Current_Event = ""

func _ready():
	search_for_parent_block(self)
	search_for_camera_position(self)
	search_for_collider(self)

	if BlockCollider != null:
		BlockCollider.set_disabled(true)

	if BlockCollider == null:
		print_debug(str(self.name) + " does not have a collider.")

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
	if Is_Door_Open == true:
		Global.Is_Door_Opened = true

	if Is_Door_Open == false:
		Global.Is_Door_Opened = false


func _process(_delta):
	set_rotation_ability()
	manage_signals()
	manage_global_door_variable()

	if Global.Current_Active_Block == self:
		if Global.Current_Event != "door":
			search_for_props(self, true)
			start_event()
	else:
		search_for_props(self, false)

	if BlockParent == Global.Current_Room:
		#print_debug(str(Global.Current_Room) + " has " + str(self.name) + " as a child.")
		self.set_visible(true)
	else:
		self.set_visible(false)

func _on_animation_player_animation_finished(_door_open):
	#print_debug(door_open + " animation completed.")
	Global.Is_In_Animation = false
	return

func _on_animation_player_animation_started(_door_open):
	#print_debug(door_open + " animation started.")
	Global.Is_In_Animation = true
	return
