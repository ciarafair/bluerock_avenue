extends Block
class_name RoomBlock

@export var RoomNumber: int
@export var IsOccupied: bool = false

func activate():
	print_rich("Activating %s" %[self.name])
	Global.stack_info(get_stack())
	self.move_to_camera_position()
	Global.Game_Data_Instance.Current_Block = self

	if self.PlayerRotation == true:
		Global.Is_Able_To_Turn = true
	else:
		Global.Is_Able_To_Turn = false

	SignalManager.room_loaded.emit(self)

	if self.Locations != []:
		for child in self.Locations:
			if child.BlockCollider != null:
				child.enable_collider()

	if self.Interactables != []:
		for child in self.Interactables:
			if child.InteractableCollider != null:
				if child.visible:
					child.enable_collider()

	if self.IsOccupied == true:
		SignalManager.game_over.emit()
		print_rich("%s is occupied." %[self.name])
		Global.stack_info(get_stack())
		return
	return

func on_screen_entered():
	print_rich("%s has entered screen." %[self.name])
	Global.stack_info(get_stack())

func on_screen_exited():
	print_rich("%s has exited screen." %[self.name])
	Global.stack_info(get_stack())

func _process(_delta):
	manage_activation_signals()

func _ready():
	block_ready()
	self.search_for_locations(self)
	self.search_for_interactables(self)
	print_rich("%s has %s locations. \n %s" %[self.name, self.Locations.size(), self.Locations])
	print_rich("%s has %s interactables. \n %s" %[self.name, self.Interactables.size(), self.Interactables])
	Global.stack_info(get_stack())
