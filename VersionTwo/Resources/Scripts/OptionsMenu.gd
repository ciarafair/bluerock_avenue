extends CanvasLayer

@onready var FpsCounterButton: Button = %FpsCounter
@onready var PlayerInfoButton: Button = %PlayerInfo
@onready var HoveringBlockButton: Button = %HoveringBlock

@onready var CurrentBlockButton: Button = %CurrentBlock
@onready var CurrentEventButton: Button = %CurrentEvent
@onready var CurrentTimeButton: Button = %CurrentTime

@onready var DevOptionsCollection: VBoxContainer = %DevOptions
@onready var NormalOptionsCollection: VBoxContainer = %NormalOptions

# Volume
@onready var MasterVolumeSlider: HSlider = %MasterVolumeSlider
@onready var MusicVolumeSlider: HSlider = %MusicVolumeSlider

@onready var ResolutionButton: OptionButton = %ResolutionButton

var Is_Dragging: bool = false

# Dev utilities
func _on_fps_counter_toggled(_button_pressed):
	Global.Is_Fps_Counter_Visible = !Global.Is_Fps_Counter_Visible

func _on_main_menu_button_up():
	SignalManager.exit_options_menu.emit()

func _on_player_info_toggled(_button_pressed):
	Global.Is_Player_Info_Visible = !Global.Is_Player_Info_Visible

func _on_hovering_block_toggled(_button_pressed):
	Global.Is_Hovering_Block_Visible = !Global.Is_Hovering_Block_Visible

func _on_current_block_toggled(_button_pressed):
	Global.Is_Current_Active_Block_Visible = !Global.Is_Current_Active_Block_Visible

func _on_current_event_toggled(_button_pressed):
	Global.Is_Current_Active_Event_Visible = !Global.Is_Current_Active_Event_Visible

func _on_option_button_item_selected(index):
	if index == 0:
		DevOptionsCollection.set_visible(true)
		NormalOptionsCollection.set_visible(false)

	if index == 1:
		NormalOptionsCollection.set_visible(true)
		DevOptionsCollection.set_visible(false)

func _on_current_time_toggled(_button_pressed):
	Global.Is_Current_Time_Info_Visible = !Global.Is_Current_Time_Info_Visible

func _on_current_room_toggled(_button_pressed):
	Global.Is_Current_Room_Info_Visible = !Global.Is_Current_Room_Info_Visible

# Volume sliders
func _on_master_volume_slider_drag_started():
	pass

func _on_master_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_master_volume_slider_drag_ended(value_changed):
	if value_changed == true:
		print_debug("Master volume changed to " + str(Global.Master_Volume_Setting))

func _on_music_volume_slider_drag_started():
	pass

func _on_music_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)

func _on_music_volume_slider_drag_ended(value_changed):
	if value_changed == true:
		print_debug("Music volume changed to " + str(Global.Music_Volume_Setting))

func manage_music_volume_sliders():
	if Global.Master_Volume_Setting != 0:
		MasterVolumeSlider.set_value_no_signal(Global.Master_Volume_Setting)

	if Global.Music_Volume_Setting != 0:
		MusicVolumeSlider.set_value_no_signal(Global.Music_Volume_Setting)

func manage_resolution_list():
	if Global.Selected_Resolution_Index == 3:
		ResolutionButton.select(3)

	if Global.Selected_Resolution_Index == 2:
		ResolutionButton.select(2)

	if Global.Selected_Resolution_Index == 1:
		ResolutionButton.select(1)

	if Global.Selected_Resolution_Index == 0:
		ResolutionButton.select(0)

func _on_resolution_button_item_selected(index):
	if index == 3:
		Global.Current_Window_Size = Vector2i(1024,546)
		Global.Selected_Resolution_Index = 3
		get_window().size = Global.Current_Window_Size

	if index == 2:
		Global.Current_Window_Size = Vector2i(1280,720)
		Global.Selected_Resolution_Index = 2
		get_window().size = Global.Current_Window_Size

	if index == 1:
		Global.Current_Window_Size = Vector2i(1600,900)
		Global.Selected_Resolution_Index = 1
		get_window().size = Global.Current_Window_Size

	if index == 0:
		Global.Current_Window_Size = Vector2i(1920,1080)
		Global.Selected_Resolution_Index = 0
		get_window().size = Global.Current_Window_Size

func _process(_delta):
	manage_music_volume_sliders()
	manage_resolution_list()

	if Global.Is_Fps_Counter_Visible == true:
		FpsCounterButton.set_pressed_no_signal(true)

	if Global.Is_Fps_Counter_Visible == false:
		FpsCounterButton.set_pressed_no_signal(false)

	if Global.Is_Player_Info_Visible == true:
		PlayerInfoButton.set_pressed_no_signal(true)

	if Global.Is_Player_Info_Visible == false:
		PlayerInfoButton.set_pressed_no_signal(false)

	if Global.Is_Hovering_Block_Visible == true:
		HoveringBlockButton.set_pressed_no_signal(true)

	if Global.Is_Hovering_Block_Visible == false:
		HoveringBlockButton.set_pressed_no_signal(false)

	if Global.Is_Current_Active_Block_Visible == true:
		CurrentBlockButton.set_pressed_no_signal(true)

	if Global.Is_Current_Active_Block_Visible == false:
		CurrentBlockButton.set_pressed_no_signal(false)

	if Global.Is_Current_Active_Event_Visible == true:
		CurrentEventButton.set_pressed_no_signal(true)

	if Global.Is_Current_Active_Event_Visible == false:
		CurrentEventButton.set_pressed_no_signal(false)

	if Global.Is_Current_Time_Info_Visible == true:
		CurrentTimeButton.set_pressed_no_signal(true)

	if Global.Is_Current_Time_Info_Visible == false:
		CurrentTimeButton.set_pressed_no_signal(false)

func _ready():
	SignalManager.options_menu_loaded.emit()
	DevOptionsCollection.set_visible(false)
	NormalOptionsCollection.set_visible(true)
