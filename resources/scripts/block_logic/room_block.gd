extends Block
class_name RoomBlock

@export var RoomNumber: int
@export var IsOccupied: bool = false

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
