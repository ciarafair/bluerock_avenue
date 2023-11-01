extends Node

const MainMenuTrackOnePath: String = "res://resources/audio/opening_screen.mp3"
const Audio_Bus_Layout: String = "res://default_bus_layout.tres"

func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound

var AudioPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
var AudioBusLayoutOne: AudioBusLayout = preload(Audio_Bus_Layout)
var Opening_Track_One_Instance: AudioStreamMP3 = load_mp3(MainMenuTrackOnePath)

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
	self.add_child(AudioPlayer)
	setup_audio_server()
