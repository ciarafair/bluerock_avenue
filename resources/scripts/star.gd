extends RichTextLabel

var TimerInstance = null

func on_timer_timeout():
	if self.text == "[font_size=40][outline_size=25][outline_color=black]✩":
		self.set_text("[font_size=40][outline_size=25][outline_color=black]✫")
		return
	if self.text == "[font_size=40][outline_size=25][outline_color=black]✫":
		self.set_text("[font_size=40][outline_size=25][outline_color=black]✩")
		return
	else:
		self.set_text("[font_size=40][outline_size=25][outline_color=black]✩")
		return

func create_timer():
	TimerInstance = Timer.new()
	self.add_child(TimerInstance)
	TimerInstance.timeout.connect(Callable(on_timer_timeout))
	TimerInstance.start(0.5)

func _process(_delta):
	if TimerInstance == null:
		create_timer()
		return
