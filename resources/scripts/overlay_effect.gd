extends Panel
class_name OverlayEffect

func manage_visibility():
	if Global.Settings_Data.Is_Overlay_Effect_Enabled == true:
		self.set_visible(true)
	else:
		self.set_visible(false)

func _process(_delta):
	manage_visibility()
