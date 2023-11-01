extends Node

const Audio_Bus_Layout: String = "res://default_bus_layout.tres"

func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound

var AudioPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
var AudioBusLayoutOne: AudioBusLayout = preload(Audio_Bus_Layout)

const Opening_Track_One_Path: String = "res://resources/audio/opening_screen.mp3"
var Opening_Track_One_Instance: AudioStreamMP3 = load_mp3(Opening_Track_One_Path)

const Door_Opening_SFX_Path: String = "res://resources/audio/open_door.mp3"
var Door_Opening_SFX_Instance: AudioStreamMP3 = load_mp3(Door_Opening_SFX_Path)
const Door_Closing_SFX_Path: String = "res://resources/audio/close_door.mp3"
var Door_Closing_SFX_Instance: AudioStreamMP3 = load_mp3(Door_Closing_SFX_Path)


@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

func on_music_player_finished():
	if Global.Is_Music_Playing == true:
		Global.Is_Music_Playing = false
		AudioPlayer.stop()
		return

func get_current_track():
	if Global.Is_Game_Active == false:
		Global.Current_Track = "Opening Track One"
		AudioPlayer.set_stream(Opening_Track_One_Instance)
		return

func on_stop_track():
	if AudioPlayer != null and Global.Is_Music_Playing == true:
		#print_debug("Stopping track: " + str(Global.Current_Track))
		Global.Is_Music_Playing = false
		Global.Current_Track = ""
		AudioPlayer.stop()
		return

	if AudioPlayer == null:
		printerr("Could not find music player to kill.")
		return

func on_start_track():
	if AudioPlayer != null and Global.Is_Music_Playing == false:
		AudioPlayer.set_bus("Music")

		Global.Is_Music_Playing = true
		get_current_track()

		if AudioPlayer.stream != null:
			print_verbose("Playing track: " +  str(Global.Current_Track))
			AudioPlayer.play()
			return

		if AudioPlayer.stream == null:
			push_warning("Could not get current track.")
			return

	if AudioPlayer == null:
		push_warning("Could not find music player to use. Trying again.")
		on_start_track()
		pass

func on_door_open(_node):
	var AudioPlayer3D: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	AudioPlayer3D.set_stream(Door_Opening_SFX_Instance)
	_node.add_child(AudioPlayer3D)
	AudioPlayer3D.set_bus("SFX")
	AudioPlayer3D.play()

func on_door_close(_node):
	var AudioPlayer3D: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	AudioPlayer3D.set_stream(Door_Closing_SFX_Instance)
	AudioPlayer3D.set_bus("SFX")
	_node.add_child(AudioPlayer3D)
	AudioPlayer3D.play(0.88)

func setup_audio_server():
	AudioServer.set_bus_layout(AudioBusLayoutOne)
	SignalManager.play_track.connect(on_start_track)
	SignalManager.stop_track.connect(on_stop_track)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), Global.Settings_Data.Master_Volume_Setting)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.Settings_Data.Music_Volume_Setting)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.Settings_Data.SFX_Volume_Setting)
	return

func _process(_delta):
	if AudioPlayer != null:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), Global.Settings_Data.Master_Volume_Setting)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.Settings_Data.Music_Volume_Setting)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.Settings_Data.SFX_Volume_Setting)
	if AudioPlayer == null:
		setup_audio_server()

func _ready():
	SignalManager.door_open_sound.connect(on_door_open)
	SignalManager.door_close_sound.connect(on_door_close)
	self.add_child(AudioPlayer)
	setup_audio_server()
