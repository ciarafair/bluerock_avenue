extends Marker3D
class_name MonsterPosition

var PositionRoom: RoomBlock
@export var PositionNumber: int
@export var Type: String

func find_parent_room(_node):
	var parent = _node.get_parent()

	if parent is RoomBlock:
		self.PositionRoom = parent
		#print_rich("Found " + str(self.name) + "'s parent room: " + str(self.PositionRoom.name))
		#Global.stack_info(get_stack())
		return
	else:
		find_parent_room(parent)

func _ready():
	find_parent_room(self)
