extends Interactable
class_name DoorHandle

func activate():
	if Global.Is_In_Animation == false:
		SignalManager.toggle_door.emit()
#		self.disable_collider()
#		print_rich("WAIT")
#		await SignalManager.door_toggled
#		print_rich("FINISHED")
#		self.enable_collider()
