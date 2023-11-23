extends Interactable
class_name LightSwitch

@export var BlockDialoguePath: JSON

func activate():
	print_debug("ACTIVATE")
	SignalManager.click_dialogue.emit(self, Global.stringify_json(Global.Hovering_Block.BlockDialoguePath))
