extends Block
class_name RoomBlock

@export var RoomNumber: int
@export var IsOccupied: bool = false

var VisibleOnScreenEnablerInstance: VisibleOnScreenNotifier3D = null

func search_for_enabler() -> VisibleOnScreenNotifier3D:
	for child in self.get_children():
		if child is VisibleOnScreenNotifier3D:
			print_rich("Found visible on screen enabler for %s." %[self.name])
			Global.stack_info(get_stack())
			return child
	return null

func activate():
	move_to_camera_position(self, true, true)
	Global.Game_Data_Instance.Current_Block = self
	print_rich("Activating %s" %[str(Global.Game_Data_Instance.Current_Block)])
	Global.stack_info(get_stack())
	#print_rich(Global.Game_Data_Instance.Current_Block_Path)
	#Global.stack_info(get_stack())

	if self.PlayerRotation == true:
		Global.Is_Able_To_Turn = true
	else:
		Global.Is_Able_To_Turn = false

	SignalManager.room_loaded.emit(self)
	if self.IsOccupied == true:
		SignalManager.game_over.emit()
		#print_rich("%s is occupied." %[self.name])
		#Global.stack_info(get_stack())

func manage_locations():
	if Global.Game_Data_Instance.Current_Block != self:
		search_for_locations(self, false)
		return

	search_for_locations(self, true)
	Global.Game_Data_Instance.Current_Room_Number = RoomNumber

func _process(_delta):
	if self.VisibleOnScreenEnablerInstance == null:
		self.VisibleOnScreenEnablerInstance = self.search_for_enabler()
	manage_activation_signals()
	manage_locations()
	set_rotation_ability()
