extends Block
class_name RoomBlock

@export var Is_Starting_Room: bool = false

func _process(_delta):
	set_rotation_ability()

	if Global.Current_Active_Block == self:
		search_for_locations(self, true)

	if Global.Current_Active_Block != self:
		search_for_locations(self, false)
