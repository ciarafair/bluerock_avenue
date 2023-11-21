extends Block
class_name LocationBlock

func manage_props():
	if Global.Game_Data_Instance.Current_Block == self:
		search_for_props(self, true)

	if Global.Game_Data_Instance.Current_Block != self:
		search_for_props(self, false)

func _process(_delta):
	manage_activation_signals()
	manage_props()
