extends Block
class_name PropBlock

func _process(_delta):
	if SignalManager.activate_block.is_connected(on_activate_block) and SignalManager.deactivate_block.is_connected(on_deactivate_block):
		if Global.Game_Data_Instance.Current_Active_Block != self:
			SignalManager.activate_block.disconnect(on_activate_block)
			SignalManager.deactivate_block.disconnect(on_deactivate_block)
	else:
		if Global.Game_Data_Instance.Current_Active_Block == self:
			SignalManager.activate_block.connect(on_activate_block)
			SignalManager.deactivate_block.connect(on_deactivate_block)

	if Global.Hovering_Block == self && !SignalManager.activate_block.is_connected(on_activate_block):
		SignalManager.activate_block.connect(on_activate_block)
