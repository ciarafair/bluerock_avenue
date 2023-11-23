extends Block
class_name LocationBlock

func toggle_sub_locations(node: Node, boolian: bool):
	for child in node.get_children():
		if child is LocationBlock:
			if boolian == true:
				child.enable_collider()
			else:
				child.disable_collider()
		toggle_sub_locations(child, boolian)
	return

func toggle_items(node: Node, boolian: bool):
	for child in node.get_children():
		if child is Interactable:
			if boolian == true:
				child.enable_collider()
			else:
				child.disable_collider()
		toggle_items(child, boolian)
	return


func manage_items(node: Node, boolian: bool):
	for child in node.get_children():
		if child is Interactable:
			if boolian == true:
				child.enable_collider()
			else:
				child.disable_collider()
		toggle_items(child, boolian)
	return

func manage_current_block():
	if Global.Game_Data_Instance.Current_Block == self:
		toggle_sub_locations(self, true)
		toggle_items(self, true)

	if Global.Game_Data_Instance.Current_Block != self:
		toggle_sub_locations(self, false)
		toggle_items(self, false)

func _process(_delta):
	manage_activation_signals()
	manage_current_block()
