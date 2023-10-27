extends StaticBody3D

var Current_Position_Number: int = 0
var WindowTimer: Timer = Timer.new()

func window_movement_management():
	if Global.Current_Event == "window":
		pass
	else:
		Current_Position_Number += 1

		if Current_Position_Number == 0:
			print_debug("@MONSTERLOGIC: Moving monster to position #" + str(Current_Position_Number))
			self.set_visible(false)

		if Current_Position_Number == 1:
			print_debug("@MONSTERLOGIC: Moving monster to position #" + str(Current_Position_Number))
			SignalManager.find_monster_position.emit(Global.Loaded_Game_World, 1)
			self.set_visible(true)

		if Current_Position_Number == 2:
			print_debug("@MONSTERLOGIC: Moving monster to position #" + str(Current_Position_Number))
			SignalManager.find_monster_position.emit(Global.Loaded_Game_World, 2)
			self.set_visible(true)

		if Current_Position_Number == 3:
			print_debug("@MONSTERLOGIC: Moving monster to position #" + str(Current_Position_Number))
			SignalManager.find_monster_position.emit(Global.Loaded_Game_World, 3)
			if !WindowTimer.timeout.is_connected(on_window_timer_timeout):
				WindowTimer.timeout.connect(on_window_timer_timeout)
			WindowTimer.one_shot = true
			WindowTimer.start(2)
			self.set_visible(true)

func on_window_timer_timeout():
	SignalManager.open_window.emit()

func on_random_tick():
	window_movement_management()

func on_monster_reset():
	Current_Position_Number = -1
	window_movement_management()
	pass

func _ready():
	SignalManager.random_tick.connect(on_random_tick)
	SignalManager.reset_monster.connect(on_monster_reset)
	self.set_visible(false)
	self.add_child(WindowTimer)
