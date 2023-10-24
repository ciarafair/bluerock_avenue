extends Block
class_name LocationBlock

func _process(_delta):
	if Global.Current_Active_Block == self:
		search_for_props(self, true)

	if Global.Current_Active_Block != self:
		search_for_props(self, false)

	if SignalManager.activate_block.is_connected(on_activate_block) and SignalManager.deactivate_block.is_connected(on_deactivate_block):
		if Global.Current_Active_Block != self:
			SignalManager.activate_block.disconnect(on_activate_block)
			SignalManager.deactivate_block.disconnect(on_deactivate_block)
	else:
		if Global.Current_Active_Block == self:
			SignalManager.activate_block.connect(on_activate_block)
			SignalManager.deactivate_block.connect(on_deactivate_block)

	if Global.Hovering_Block == self and !SignalManager.activate_block.is_connected(on_activate_block):
		SignalManager.activate_block.connect(on_activate_block)
