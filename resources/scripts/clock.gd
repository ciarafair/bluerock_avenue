extends SubViewport

@onready var HourLabel: Label = %Hour
@onready var MinuteLabel: Label = %Minute
@onready var SeperatorLabel: Label = %Seperator
@onready var AMMeridian: Label = %Am
@onready var PMMeridian: Label = %Pm

var frame_count: int = 0
var frame_bool: bool = true
var frames_to_change: int = 50

var HourString: String = "00"
var MinuteString: String = "02"

var ActiveColor: Color = Color(1, 0, 0.016)
var DisabledColor: Color = Color(0.275, 0, 0, 0.612)

func manage_hour():
	if Global.Game_Data_Instance.Time_Hour > 10:
		HourString = str(Global.Game_Data_Instance.Time_Hour)
	else:
		HourString = "0" + str(Global.Game_Data_Instance.Time_Hour)

func manage_minute():
	if Global.Game_Data_Instance.Time_Minute < 10:
		MinuteString = "0" + str(Global.Game_Data_Instance.Time_Minute)
	elif Global.Game_Data_Instance.Time_Minute == 0:
		MinuteString = "00"
	else:
		MinuteString = str(Global.Game_Data_Instance.Time_Minute)

func manage_meridian():
	if Global.Game_Data_Instance.Time_Hour < 10 or Global.Game_Data_Instance.Time_Hour == 12 && Global.Game_Data_Instance.Time_Minute != 0:
		AMMeridian.label_settings.font_color = ActiveColor
		PMMeridian.label_settings.font_color = DisabledColor
	else:
		AMMeridian.label_settings.font_color = DisabledColor
		PMMeridian.label_settings.font_color = ActiveColor

func manage_labels():
	HourLabel.text = HourString
	MinuteLabel.text = MinuteString

func check_count():
	frame_bool = !frame_bool
	if frame_bool == true:
		SeperatorLabel.label_settings.font_color = DisabledColor
	else:
		SeperatorLabel.label_settings.font_color = ActiveColor

func _process(_delta):
	frame_count += 1
	if frame_count >= frames_to_change:
		print_rich("Toggling seperator on clock")
		Global.stack_info(get_stack())
		check_count()
		frame_count = 0

	manage_hour()
	manage_minute()
	manage_meridian()
	manage_labels()
	pass
