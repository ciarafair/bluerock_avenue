extends CanvasLayer

# Collections
@onready var DevOptionsCollection: VBoxContainer = %DevOptions
@onready var NormalOptionsCollection: VBoxContainer = %NormalOptions

var Is_Dragging: bool = false

# Dev utilities
@onready var FpsCounterButton: Button = %FpsCounter
func _on_fps_counter_toggled(_button_pressed):
	Global.Settings_Data.Is_Fps_Counter_Visible = !Global.Settings_Data.Is_Fps_Counter_Visible

@onready var PlayerInfoButton: Button = %PlayerInfo
func _on_player_info_toggled(_button_pressed):
	Global.Settings_Data.Is_Player_Info_Visible = !Global.Settings_Data.Is_Player_Info_Visible

@onready var HoveringBlockButton: Button = %HoveringBlock
func _on_hovering_block_toggled(_button_pressed):
	Global.Settings_Data.Is_Hovering_Block_Visible = !Global.Settings_Data.Is_Hovering_Block_Visible

@onready var CurrentBlockButton: Button = %CurrentBlock
func _on_current_block_toggled(_button_pressed):
	Global.Settings_Data.Is_Current_Active_Block_Visible = !Global.Settings_Data.Is_Current_Active_Block_Visible

@onready var CurrentEventButton: Button = %CurrentEvent
func _on_current_event_toggled(_button_pressed):
	Global.Settings_Data.Is_Current_Active_Event_Visible = !Global.Settings_Data.Is_Current_Active_Event_Visible

@onready var CurrentTimeButton: Button = %CurrentTime
func _on_current_time_toggled(_button_pressed):
	Global.Settings_Data.Is_Current_Time_Info_Visible = !Global.Settings_Data.Is_Current_Time_Info_Visible

@onready var PlayerCurrentRoomButton: Button = %CurrentRoom
func _on_current_room_toggled(_button_pressed):
	Global.Settings_Data.Is_Player_Current_Room_Info_Visible = !Global.Settings_Data.Is_Player_Current_Room_Info_Visible

@onready var MonsterInfoButton: Button = %MonsterInfo
func _on_monster_info_toggled(_button_pressed):
	Global.Settings_Data.Is_Monster_Info_Visible = !Global.Settings_Data.Is_Monster_Info_Visible

# Normal Options
## Volume sliders
@onready var MasterVolumeSlider: HSlider = %MasterVolumeSlider
@onready var MusicVolumeSlider: HSlider = %MusicVolumeSlider

func _on_master_volume_slider_drag_started():
	pass

func _on_master_volume_slider_value_changed(value):
	Global.Settings_Data.Master_Volume_Setting = value

func _on_master_volume_slider_drag_ended(value_changed):
	if value_changed == true:
		#print_debug("Master volume changed to " + str(Global.Master_Volume_Setting))
		pass

func _on_music_volume_slider_drag_started():
	pass

func _on_music_volume_slider_value_changed(value):
	Global.Settings_Data.Music_Volume_Setting = value

func _on_music_volume_slider_drag_ended(value_changed):
	if value_changed == true:
		#print_debug("Music volume changed to " + str(Global.Music_Volume_Setting))
		pass

func manage_music_volume_sliders():
	if Global.Settings_Data.Master_Volume_Setting != MasterVolumeSlider.value:
		MasterVolumeSlider.set_value_no_signal(Global.Settings_Data.Master_Volume_Setting)

	if Global.Settings_Data.Music_Volume_Setting != MusicVolumeSlider.value:
		MusicVolumeSlider.set_value_no_signal(Global.Settings_Data.Music_Volume_Setting)

## Resolution
@onready var ResolutionButton: OptionButton = %ResolutionButton

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

# Internal
func _on_option_button_item_selected(index):
	if index == 0:
		DevOptionsCollection.set_visible(true)
		NormalOptionsCollection.set_visible(false)

	if index == 1:
		NormalOptionsCollection.set_visible(true)
		DevOptionsCollection.set_visible(false)

func visibility_check():
	if Global.Settings_Data.Is_Fps_Counter_Visible == true:
		FpsCounterButton.set_pressed_no_signal(true)

	if Global.Settings_Data.Is_Fps_Counter_Visible == false:
		FpsCounterButton.set_pressed_no_signal(false)

	if Global.Settings_Data.Is_Player_Info_Visible == true:
		PlayerInfoButton.set_pressed_no_signal(true)

	if Global.Settings_Data.Is_Player_Info_Visible == false:
		PlayerInfoButton.set_pressed_no_signal(false)

	if Global.Settings_Data.Is_Hovering_Block_Visible == true:
		HoveringBlockButton.set_pressed_no_signal(true)

	if Global.Settings_Data.Is_Hovering_Block_Visible == false:
		HoveringBlockButton.set_pressed_no_signal(false)

	if Global.Settings_Data.Is_Current_Active_Block_Visible == true:
		CurrentBlockButton.set_pressed_no_signal(true)

	if Global.Settings_Data.Is_Current_Active_Block_Visible == false:
		CurrentBlockButton.set_pressed_no_signal(false)

	if Global.Settings_Data.Is_Current_Active_Event_Visible == true:
		CurrentEventButton.set_pressed_no_signal(true)

	if Global.Settings_Data.Is_Current_Active_Event_Visible == false:
		CurrentEventButton.set_pressed_no_signal(false)

	if Global.Settings_Data.Is_Current_Time_Info_Visible == true:
		CurrentTimeButton.set_pressed_no_signal(true)

	if Global.Settings_Data.Is_Current_Time_Info_Visible == false:
		CurrentTimeButton.set_pressed_no_signal(false)

	if Global.Settings_Data.Is_Player_Current_Room_Info_Visible == true:
		PlayerCurrentRoomButton.set_pressed_no_signal(true)

	if Global.Settings_Data.Is_Player_Current_Room_Info_Visible == false:
		PlayerCurrentRoomButton.set_pressed_no_signal(false)

	if Global.Settings_Data.Is_Monster_Info_Visible == true:
		MonsterInfoButton.set_pressed_no_signal(true)

	if Global.Settings_Data.Is_Monster_Info_Visible == false:
		MonsterInfoButton.set_pressed_no_signal(false)

func _on_main_menu_button_up():
	SignalManager.exit_options_menu.emit()

func _on_save_changes_button_up():
	SignalManager.save_settings.emit()

func _process(_delta):
	manage_music_volume_sliders()
	manage_resolution_list()
	visibility_check()

func _ready():
	SignalManager.options_menu_loaded.emit()
	DevOptionsCollection.set_visible(false)
	NormalOptionsCollection.set_visible(true)
