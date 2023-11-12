extends CanvasLayer
class_name OverlayEffect
@onready var PanelInstance = $Panel
@onready var OverlayMaterial = preload(Path.OverlayMaterialPath)

func manage_visibility():
	if Global.Settings_Data_Instance.Is_Overlay_Effect_Enabled == true:
		self.set_visible(true)
	else:
		self.set_visible(false)

func _ready():
	Global.Loaded_Overlay_Effect = self
	PanelInstance.set_material(OverlayMaterial)
	OverlayMaterial.set_shader_parameter("Resolution", Vector2(get_window().size.x * 720, get_window().size.y * 480 ))

func _process(_delta):
	manage_visibility()
