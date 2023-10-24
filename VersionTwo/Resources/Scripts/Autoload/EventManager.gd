extends Node

var IS_FLASHLIGHT_TOGGLEABLE = true
var ClockTimer: Timer = Timer.new()
var RandomTimer: Timer = Timer.new()

var Is_Clock_Timer_Running: bool = false
var Is_Random_Timer_Running: bool = false

var minute_int: int = 30
var hour_int: int = 11
var meridiem: String

var random_int: int

func manage_time():
	if minute_int >= 60:
		minute_int = 0
		hour_int += 1

	if hour_int > 12:
		hour_int = 1

	if hour_int == 11:
		meridiem = "pm"
	else:
		meridiem = "am"

	if minute_int != 0:
		Global.time_string = str(hour_int) + ":" + str(minute_int) + meridiem
	else:
		Global.time_string = str(hour_int) + ":00" + meridiem

func on_clock_timeout():
	minute_int = minute_int + 10
	manage_time()
	#print_debug("Clock timer timed out.")

func manage_random_events():
	if hour_int >= 1 && hour_int < 11:
		if Is_Random_Timer_Running == false:
			RandomTimer.start(5)
			Is_Random_Timer_Running = true

func on_random_timeout():
	var timeout_int = randi_range(1, 10)
	if timeout_int == random_int:
		print_debug("Random event. " + str(timeout_int) + " == " + str(random_int))

	if timeout_int != random_int:
		print_debug("Random event failed. " + str(timeout_int) + " != " + str(random_int))

func _process(_delta):
	manage_random_events()

	if Global.Is_Game_Active == true && get_tree().paused == false:
		if Is_Clock_Timer_Running == false:
			manage_time()
			ClockTimer.start(15)
			Is_Clock_Timer_Running = true

func _ready():
	random_int = randi_range(1, 5)
	self.add_child(ClockTimer)
	self.add_child(RandomTimer)
	ClockTimer.timeout.connect(on_clock_timeout)
	RandomTimer.timeout.connect(on_random_timeout)
	ClockTimer.one_shot = false
	RandomTimer.one_shot = false

