extends PropBlock
class_name LightSwitch

var lightswitch_dialogue = preload(Path.LightswitchDialoguePath)

func on_activate_block(node: Block):
	if Global.DialogueBoxInstance == null:
		SignalManager.load_dialogue_box.emit()
	SignalManager.click_dialogue.emit(node, self.lightswitch_dialogue)
	return
