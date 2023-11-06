extends VideoStreamPlayer

func _ready():
	var video = preload("res://resources/video/stock_cartoon_cropped.ogv")
	self.set_stream(video)
	set_process(true)

func _process(_delta):
	if not self.is_playing():
		self.play()
