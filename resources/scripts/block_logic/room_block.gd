extends Block
class_name RoomBlock

@export var RoomNumber: int

func _process(_delta):
	set_rotation_ability()

	if Global.Game_Data_Instance.Current_Block == self:
		search_for_locations(self, true)
		Global.Game_Data_Instance.Current_Room_Number = RoomNumber

	if Global.Game_Data_Instance.Current_Block != self:
		search_for_locations(self, false)
