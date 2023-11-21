extends Block
class_name RoomBlock

@export var RoomNumber: int
@export var IsOccupied: bool = false

func activate():
	#print_debug("Activating " + str(Global.Current_Block))
	move_to_camera_position(self, true, true)
	Global.Game_Data_Instance.Current_Block = self
	#print_debug(Global.Game_Data_Instance.Current_Block_Path)

	if self.PlayerRotation == true:
		Global.Is_Able_To_Turn = true
	else:
		Global.Is_Able_To_Turn = false

	SignalManager.room_loaded.emit(self)
	if self.IsOccupied == true:
		print_debug("%s is occupied." %[self.name])
		SignalManager.game_over.emit()

func manage_locations():
	if Global.Game_Data_Instance.Current_Block != self:
		search_for_locations(self, false)
		return

	search_for_locations(self, true)
	Global.Game_Data_Instance.Current_Room_Number = RoomNumber

func _process(_delta):
	manage_activation_signals()
	manage_locations()
	set_rotation_ability()
