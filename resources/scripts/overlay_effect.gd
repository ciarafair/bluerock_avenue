extends Panel
class_name OverlayEffect

@onready var OverlayMaterial = preload(Path.OverlayMaterialPath)

func manage_visibility():
	if Global.Settings_Data.Is_Overlay_Effect_Enabled == true:
		self.set_visible(true)
	else:
		self.set_visible(false)

func _ready():
	self.set_material(OverlayMaterial)
	OverlayMaterial.set_shader_parameter("Resolution", Vector2(get_window().size.x * 720, get_window().size.y * 480 ))

func _process(_delta):
	manage_visibility()
