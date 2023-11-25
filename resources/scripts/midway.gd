extends Interactable

func find_room(node: Node, number: int):
	for child in node.get_children(true):
		if child is RoomBlock:
			if child.RoomNumber == number:
				child.activate()
				return
		else:
			find_room(child, number)

func activate():
	if Global.Game_Data_Instance.Current_Room.RoomNumber == 2:
		print_debug("Activating room number 3.")
		find_room(Global.Object_Loader, 3)
		return
	elif Global.Game_Data_Instance.Current_Room.RoomNumber == 3:
		print_debug("Activating room number 2.")
		find_room(Global.Object_Loader, 2)
		return
	else:
		pass
