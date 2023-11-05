extends Node

const random_tick_interval: float = 0.5
const clock_tick_interval: float = 15

var IS_FLASHLIGHT_TOGGLEABLE = true
var ClockTimer: Timer = Timer.new()
var RandomTimer: Timer = Timer.new()

var Is_Clock_Timer_Running: bool = false
var Is_Random_Timer_Running: bool = false

var minute_int: int = 30
var hour_int: int = 11
var meridiem: String

var target_number: int
var number_pool = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

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
		Global.Game_Data.Time_String = str(hour_int) + ":" + str(minute_int) + meridiem
		Global.Game_Data.Time_Hour = hour_int
		Global.Game_Data.Time_Minute = minute_int
	else:
		Global.Game_Data.Time_String = str(hour_int) + ":00" + meridiem
		Global.Game_Data.Time_Hour = hour_int
		Global.Game_Data.Time_Minute = minute_int

func on_clock_timeout():
	minute_int = minute_int + 10
	#print_debug("Clock timer timed out.")

func get_random_number_from_pool():
	if number_pool.size() == 0:
		return -1
	var index = randi_range(0, number_pool.size() - 1)
	return number_pool[index]

func on_random_timeout():
	while number_pool.size() > 0:
		var guess = get_random_number_from_pool()
		if guess == target_number:
			#print_debug("Match. " + str(guess) + " == " + str(target_number))
			SignalManager.random_tick.emit()
			number_pool = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
			#print_debug("Reset number pool: " + str(number_pool))
			return
		else:
			#print_debug("No match. " + str(guess) + " != " + str(target_number))
			number_pool.erase(guess)
			#print_debug("Updated number pool: " + str(number_pool))
			return
	print("No more numbers in the pool.")

func start_random_timer():
	if Is_Random_Timer_Running == false:
		RandomTimer.timeout.connect(on_random_timeout)
		RandomTimer.one_shot = false
		RandomTimer.start(random_tick_interval)
		Is_Random_Timer_Running = true

func start_clock_timer():
	if Is_Clock_Timer_Running == false:
		ClockTimer.timeout.connect(on_clock_timeout)
		ClockTimer.one_shot = false
		ClockTimer.start(clock_tick_interval)
		Is_Clock_Timer_Running = true

func _process(_delta):
	if Global.Is_Game_Active == true && get_tree().paused == false:
		manage_time()
		start_clock_timer()
		start_random_timer()

	if Global.Is_Game_Active == false:
		ClockTimer.stop()
		RandomTimer.stop()

	if get_tree().paused == true:
		ClockTimer.stop()
		RandomTimer.stop()

func _ready():
	target_number = randi_range(1, 10)
	self.add_child(ClockTimer)
	self.add_child(RandomTimer)
