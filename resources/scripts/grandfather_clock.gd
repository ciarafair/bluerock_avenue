extends StaticBody3D

var has_run: bool = false

func _process(_delta):
	if self.has_run == false:
		self.has_run = true
		SignalManager.clock_ticking.emit(self)
		return
