extends Interactable

func manage_visibility():
	if Global.Game_Data_Instance.PlayerInventory.has(self.name):
		self.set_visible(false)
		self.disable_collider()
		return
	self.set_visible(true)
	self.enable_collider()
	return

func _process(_delta):
	manage_visibility()
