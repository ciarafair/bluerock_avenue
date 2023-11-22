extends Node

const random_tick_interval: float = 15
const clock_tick_interval: float = 15

var IS_FLASHLIGHT_TOGGLEABLE = true
var ClockTimer: Timer
var RandomTimer: Timer

var Is_Clock_Timer_Running: bool = false
var Is_Random_Timer_Running: bool = false

var meridiem: String

var target_number: int
var number_pool = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

var RandomTickInt: int = 0

func manage_time():
	if Global.Game_Data_Instance.Time_Minute >= 60:
		Global.Game_Data_Instance.Time_Minute = 0
		Global.Game_Data_Instance.Time_Hour += 1

	if Global.Game_Data_Instance.Time_Hour > 12:
		Global.Game_Data_Instance.Time_Hour = 1

	if Global.Game_Data_Instance.Time_Hour == 11:
		meridiem = "pm"
	else:
		meridiem = "am"

	if Global.Game_Data_Instance.Time_Minute != 0:
		Global.Game_Data_Instance.Time_String = "%s:%s%s" % [str(Global.Game_Data_Instance.Time_Hour), str(Global.Game_Data_Instance.Time_Minute), str(meridiem)]
	else:
		Global.Game_Data_Instance.Time_String = "%s:00%s" % [str(Global.Game_Data_Instance.Time_Hour), str(meridiem)]

func on_clock_timeout():
	Global.Game_Data_Instance.Time_Minute = Global.Game_Data_Instance.Time_Minute + 10
	#print_rich("Clock timer timed out.")
	#Global.stack_info(get_stack())

func get_random_number_from_pool():
	if number_pool.size() == 0:
		return -1
	var index = randi_range(0, number_pool.size() - 1)
	return number_pool[index]

func on_random_timeout():
	RandomTickInt += 1

func start_random_timer():
	RandomTimer.one_shot = false
	RandomTimer.start(random_tick_interval)
	Is_Random_Timer_Running = true

func start_clock_timer():
	ClockTimer.one_shot = false
	ClockTimer.start(clock_tick_interval)
	Is_Clock_Timer_Running = true

func random_tick(_delta):
	while number_pool.size() > 0:
		var guess = get_random_number_from_pool()
		if guess == target_number:
			#print_rich("Match at %s: %s == %s" %[delta, guess, target_number])
			#Global.stack_info(get_stack())
			if Global.Game_Data_Instance.Is_Monster_Active == true:
				Global.Game_Data_Instance.Monster_Current_Stage += 1
			number_pool = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
			#print_rich("Reset number pool: %s" %[number_pool])
			#Global.stack_info(get_stack())
			return
		else:
			#print_rich("Skip at %s: %s == %s" %[delta, guess, target_number])
			#Global.stack_info(get_stack())
			number_pool.erase(guess)
			#print_rich("Updated number pool: %s" %[number_pool])
			#Global.stack_info(get_stack())
			return
	printerr("No more numbers in the pool.")


func _process(delta):
	if !ClockTimer:
		ClockTimer = Timer.new()
		ClockTimer.timeout.connect(on_clock_timeout)
		self.add_child(ClockTimer)

	if !RandomTimer:
		RandomTimer = Timer.new()
		RandomTimer.timeout.connect(Callable(on_random_timeout))
		self.add_child(RandomTimer)

	if RandomTickInt == 1:
		random_tick(delta)
		RandomTickInt -=1

	if Global.Is_Game_Active == true && get_tree().paused == false:
		manage_time()
		if ClockTimer.is_stopped():
			start_clock_timer()
		if RandomTimer.is_stopped():
			start_random_timer()

	if Global.Is_Game_Active == false:
		ClockTimer.stop()
		RandomTimer.stop()

	if get_tree().paused == true:
		ClockTimer.stop()
		RandomTimer.stop()

func _ready():
	target_number = randi_range(1, 10)
	#print_rich("Target number for event is %s" %[target_number])
	#Global.stack_info(get_stack())
