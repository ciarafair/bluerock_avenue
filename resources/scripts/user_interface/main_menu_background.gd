extends Node3D

func _process(_delta):
	if Global.Is_Game_Active == false:
		pass
	else:
		self.queue_free()
