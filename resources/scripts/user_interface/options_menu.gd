extends CanvasLayer

var Is_Dragging: bool = false

# Dev utilities
@onready var FpsCounterButton: Button = %FpsCounter
func _on_fps_counter_toggled(_button_pressed):
	Global.Settings_Data_Instance.Is_Fps_Counter_Visible = !Global.Settings_Data_Instance.Is_Fps_Counter_Visible

@onready var PlayerInfoButton: Button = %PlayerInfo
func _on_player_info_toggled(_button_pressed):
	Global.Settings_Data_Instance.Is_Player_Info_Visible = !Global.Settings_Data_Instance.Is_Player_Info_Visible

@onready var HoveringBlockButton: Button = %HoveringBlock
func _on_hovering_block_toggled(_button_pressed):
	Global.Settings_Data_Instance.Is_Hovering_Block_Visible = !Global.Settings_Data_Instance.Is_Hovering_Block_Visible

@onready var CurrentBlockButton: Button = %CurrentBlock
func _on_current_block_toggled(_button_pressed):
	Global.Settings_Data_Instance.Is_Current_Block_Visible = !Global.Settings_Data_Instance.Is_Current_Block_Visible

@onready var CurrentEventButton: Button = %CurrentEvent
func _on_current_event_toggled(_button_pressed):
	Global.Settings_Data_Instance.Is_Current_Active_Event_Visible = !Global.Settings_Data_Instance.Is_Current_Active_Event_Visible

@onready var CurrentTimeButton: Button = %CurrentTime
func _on_current_time_toggled(_button_pressed):
	Global.Settings_Data_Instance.Is_Current_Time_Info_Visible = !Global.Settings_Data_Instance.Is_Current_Time_Info_Visible

@onready var PlayerCurrentRoomButton: Button = %CurrentRoom
func _on_current_room_toggled(_button_pressed):
	Global.Settings_Data_Instance.Is_Player_Current_Room_Info_Visible = !Global.Settings_Data_Instance.Is_Player_Current_Room_Info_Visible

@onready var MonsterInfoButton: Button = %MonsterInfo
func _on_monster_info_toggled(_button_pressed):
	Global.Settings_Data_Instance.Is_Monster_Info_Visible = !Global.Settings_Data_Instance.Is_Monster_Info_Visible

# Volume Options
## Volume sliders
@onready var MasterVolumeSlider: HSlider = %MasterVolumeSlider
@onready var MasterVolumePercentage: Label = %MasterPercent

@onready var MusicVolumeSlider: HSlider = %MusicVolumeSlider
@onready var MusicVolumePercentage: Label = %MusicPercent

@onready var SFXVolumeSlider: HSlider = %SFXVolumeSlider
@onready var SFXVolumePercentage: Label = %SFXPercent

func _on_master_volume_slider_value_changed(value):
	Global.Settings_Data_Instance.Master_Volume_Setting = value

func _on_music_volume_slider_value_changed(value):
	Global.Settings_Data_Instance.Music_Volume_Setting = value

func _on_sfx_volume_slider_value_changed(value):
	Global.Settings_Data_Instance.SFX_Volume_Setting = value

func decibles_to_percentage(dB_value: float, min_dB: float, max_dB: float) -> float:
	var percentage: float = (dB_value - min_dB) / (max_dB - min_dB) * 100
	return percentage

func manage_volume_sliders():
	var MasterVolume: float = Global.Settings_Data_Instance.Master_Volume_Setting
	var MusicVolume: float = Global.Settings_Data_Instance.Music_Volume_Setting
	var SFXVolume: float = Global.Settings_Data_Instance.SFX_Volume_Setting

	if Global.Settings_Data_Instance.Master_Volume_Setting != MasterVolumeSlider.value:
		MasterVolumeSlider.set_value_no_signal(MasterVolume)

	if Global.Settings_Data_Instance.Music_Volume_Setting != MusicVolumeSlider.value:
		MusicVolumeSlider.set_value_no_signal(MusicVolume)

	if Global.Settings_Data_Instance.SFX_Volume_Setting != SFXVolumeSlider.value:
		SFXVolumeSlider.set_value_no_signal(SFXVolume)

	MasterVolumePercentage.text = str(snapped(decibles_to_percentage(MasterVolume, MasterVolumeSlider.min_value, MasterVolumeSlider.max_value), 1)) + "%"
	MusicVolumePercentage.text = str(snapped(decibles_to_percentage(MusicVolume, MusicVolumeSlider.min_value, MusicVolumeSlider.max_value), 1)) + "%"
	SFXVolumePercentage.text = str(snapped(decibles_to_percentage(SFXVolume, SFXVolumeSlider.min_value, SFXVolumeSlider.max_value), 1)) + "%"

# General Options
## Resolution
@onready var ResolutionButton: OptionButton = %ResolutionButton

func manage_resolution_list():
	if Global.Settings_Data_Instance.Selected_Resolution_Index == 0:
		ResolutionButton.select(0)

	if Global.Settings_Data_Instance.Selected_Resolution_Index == 1:
		ResolutionButton.select(1)

	if Global.Settings_Data_Instance.Selected_Resolution_Index == 2:
		ResolutionButton.select(2)

	if Global.Settings_Data_Instance.Selected_Resolution_Index == 3:
		ResolutionButton.select(3)

func _on_resolution_button_item_selected(index):
	Global.set_window_resolution(index)

@onready var SensitivitySlider = %SensitivitySlider
func _on_sensitivity_slider_value_changed(value):
	Global.Settings_Data_Instance.Mouse_Sensitivity = value

func manage_sensitivity_slider():
	if Global.Settings_Data_Instance.Mouse_Sensitivity != SensitivitySlider.value:
		SensitivitySlider.set_value_no_signal(Global.Settings_Data_Instance.Mouse_Sensitivity)

@onready var OverlayEffectButton = %OverlayEffect
func _on_overlay_effect_toggled(_button_pressed):
	Global.Settings_Data_Instance.Is_Overlay_Effect_Enabled = !Global.Settings_Data_Instance.Is_Overlay_Effect_Enabled

@onready var IntroAnimationButton = %IntroAnimation
func _on_intro_animation_toggled(_button_pressed):
	Global.Settings_Data_Instance.Skip_Introduction = !Global.Settings_Data_Instance.Skip_Introduction


func visibility_check():
# General Settings
	if Global.Settings_Data_Instance.Is_Overlay_Effect_Enabled == true:
		OverlayEffectButton.set_pressed_no_signal(true)

	if Global.Settings_Data_Instance.Is_Overlay_Effect_Enabled == false:
		OverlayEffectButton.set_pressed_no_signal(false)

# Developer Settings
	if Global.Settings_Data_Instance.Is_Fps_Counter_Visible == true:
		FpsCounterButton.set_pressed_no_signal(true)

	if Global.Settings_Data_Instance.Is_Fps_Counter_Visible == false:
		FpsCounterButton.set_pressed_no_signal(false)

	if Global.Settings_Data_Instance.Is_Player_Info_Visible == true:
		PlayerInfoButton.set_pressed_no_signal(true)

	if Global.Settings_Data_Instance.Is_Player_Info_Visible == false:
		PlayerInfoButton.set_pressed_no_signal(false)

	if Global.Settings_Data_Instance.Is_Hovering_Block_Visible == true:
		HoveringBlockButton.set_pressed_no_signal(true)

	if Global.Settings_Data_Instance.Is_Hovering_Block_Visible == false:
		HoveringBlockButton.set_pressed_no_signal(false)

	if Global.Settings_Data_Instance.Is_Current_Block_Visible == true:
		CurrentBlockButton.set_pressed_no_signal(true)

	if Global.Settings_Data_Instance.Is_Current_Block_Visible == false:
		CurrentBlockButton.set_pressed_no_signal(false)

	if Global.Settings_Data_Instance.Is_Current_Active_Event_Visible == true:
		CurrentEventButton.set_pressed_no_signal(true)

	if Global.Settings_Data_Instance.Is_Current_Active_Event_Visible == false:
		CurrentEventButton.set_pressed_no_signal(false)

	if Global.Settings_Data_Instance.Is_Current_Time_Info_Visible == true:
		CurrentTimeButton.set_pressed_no_signal(true)

	if Global.Settings_Data_Instance.Is_Current_Time_Info_Visible == false:
		CurrentTimeButton.set_pressed_no_signal(false)

	if Global.Settings_Data_Instance.Is_Player_Current_Room_Info_Visible == true:
		PlayerCurrentRoomButton.set_pressed_no_signal(true)

	if Global.Settings_Data_Instance.Is_Player_Current_Room_Info_Visible == false:
		PlayerCurrentRoomButton.set_pressed_no_signal(false)

	if Global.Settings_Data_Instance.Is_Monster_Info_Visible == true:
		MonsterInfoButton.set_pressed_no_signal(true)

	if Global.Settings_Data_Instance.Is_Monster_Info_Visible == false:
		MonsterInfoButton.set_pressed_no_signal(false)

	if Global.Settings_Data_Instance.Skip_Introduction == true:
		IntroAnimationButton.set_pressed_no_signal(true)

	if Global.Settings_Data_Instance.Skip_Introduction == false:
		IntroAnimationButton.set_pressed_no_signal(false)

func _on_main_menu_button_up():
	self.set_visible(false)
	SignalManager.save_settings_data.emit()
	SignalManager.exit_options_menu.emit()
	return

func _on_save_changes_button_up():
	SignalManager.activate_popup.emit("Save-data written.", 1.5)
	SignalManager.save_settings_data.emit()
	return

func _on_tree_exiting():
	Global.Loaded_Options_Menu = null

func _process(_delta):
	manage_volume_sliders()
	manage_sensitivity_slider()
	manage_resolution_list()
	visibility_check()

func _ready():
	self.set_visible(false)
	Global.Loaded_Options_Menu = self
	SignalManager.show_options_menu.connect(Callable(self.set_visible).bind(true))
	return
