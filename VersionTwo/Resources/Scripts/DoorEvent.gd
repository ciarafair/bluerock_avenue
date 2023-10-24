extends LocationBlock
class_name DoorBlock

@onready var AnimationPlayerInstance: AnimationPlayer = $AnimationPlayer
@export var Is_Door_Open: bool
@export var Door_Number: int

func on_open_door():
	if Is_Door_Open == true:
		return

	if Is_Door_Open == false:
		AnimationPlayerInstance.play("peek_door")

func on_close_door():
	AnimationPlayerInstance.play_backwards("peek_door")

func start_event():
	SignalManager.enable_other_side_of_door.emit(Door_Number)
	Global.Current_Event = "door"
	if SignalManager.open_door.is_connected(on_open_door):
		pass
	else:
		SignalManager.open_door.connect(on_open_door)

	if SignalManager.close_door.is_connected(on_close_door):
		pass
	else:
		SignalManager.close_door.connect(on_close_door)

func on_stop_event():
	print_debug("Stopping door event.")
	SignalManager.disable_other_side_of_door.emit(Door_Number)
	Global.Current_Event = ""

func _ready():
	search_for_parent_block(self)
	search_for_camera_position(self)
	search_for_collider(self)

	if BlockCollider != null:
		BlockCollider.set_disabled(true)

	if BlockCollider == null:
		print_debug(str(self.name) + " does not have a collider.")

func _process(_delta):
	set_rotation_ability()
	if Is_Door_Open == true:
		Global.Is_Door_Opened = true

	if Is_Door_Open == false:
		Global.Is_Door_Opened = false

	if Global.Current_Active_Block == self && Global.Current_Event != "door":
		search_for_props(self, true)
		start_event()

	if Global.Current_Active_Block != self:
		search_for_props(self, false)


	if Global.Current_Active_Block == self:
		if !SignalManager.stop_event.is_connected(on_stop_event):
			SignalManager.stop_event.connect(on_stop_event)

		if !SignalManager.activate_block.is_connected(on_activate_block) and !SignalManager.deactivate_block.is_connected(on_deactivate_block):
			SignalManager.activate_block.connect(on_activate_block)
			SignalManager.deactivate_block.connect(on_deactivate_block)
	else:
		if Global.Hovering_Block == self:
			if !SignalManager.activate_block.is_connected(on_activate_block):
				SignalManager.activate_block.connect(on_activate_block)

		if SignalManager.stop_event.is_connected(on_stop_event):
			SignalManager.stop_event.disconnect(on_stop_event)

		if SignalManager.activate_block.is_connected(on_activate_block) and SignalManager.deactivate_block.is_connected(on_deactivate_block):
			SignalManager.activate_block.disconnect(on_activate_block)
			SignalManager.deactivate_block.disconnect(on_deactivate_block)

func _on_animation_player_animation_finished(_door_open):
	#print_debug(door_open + " animation completed.")
	Global.Is_In_Animation = false
	return

func _on_animation_player_animation_started(_door_open):
	#print_debug(door_open + " animation started.")
	Global.Is_In_Animation = true
	return
