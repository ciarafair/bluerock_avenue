extends StaticBody3D

func _ready():
	SignalManager.clock_ticking.emit(self)
