extends Area

onready var Cameras = $Viewport/Cameras
onready var AnimPlayer = $AnimationPlayer

var CameraNodes: Array
var CurrentCamera: int = 0

var Power: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	CameraNodes = Cameras.get_children()

func _input(event):
	if event.is_action_pressed("ActionKey"):
		if get_overlapping_areas().size() == 1:
			if Power == false:
				AnimPlayer.play("On-Off")
				Power = true
			else:
				AnimPlayer.play_backwards("On-Off")
				Power = false

	if event.is_action_pressed("ChangeChannel"):
		if get_overlapping_areas().size() == 1:
			if Power == true:
				CurrentCamera += 1
				if CurrentCamera == CameraNodes.size():
					CurrentCamera = 0
				var SecurityCam = CameraNodes[CurrentCamera].SecurityCamera
				SecurityCam.make_current()

