extends Node

const MainMenuTrackOnePath: String = "res://resources/audio/opening_screen.mp3"

func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound

var AudioPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
var AudioBusLayoutOne: AudioBusLayout = preload(Global.Audio_Bus_Layout)
var Opening_Track_One_Instance: AudioStreamMP3 = load_mp3(MainMenuTrackOnePath)

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

func on_music_player_finished():
	if Global.Is_Music_Playing == true:
		Global.Is_Music_Playing = false
		AudioPlayer.queue_free()

func get_current_track():
	if Global.Is_Game_Active == false:
		Global.Current_Track = "Opening Track One"
		AudioPlayer.set_stream(Opening_Track_One_Instance)

func on_stop_track():
	if AudioPlayer != null and Global.Is_Music_Playing == true:
		#print_debug("Stopping track: " + str(Global.Current_Track))
		Global.Is_Music_Playing = false
		Global.Current_Track = ""
		AudioPlayer.stop()
		AudioPlayer.queue_free()
		return

	if AudioPlayer == null:
		#print_debug("Could not find music player to kill.")
		return

func on_start_track():
	if AudioPlayer != null and Global.Is_Music_Playing == false:
		AudioPlayer.set_bus("Music")

		Global.Is_Music_Playing = true
		get_current_track()

		if AudioPlayer.stream != null:
			#print_debug("Playing track: " +  str(Global.Current_Track))
			AudioPlayer.play()
			return

		if AudioPlayer.stream == null:
			#print_debug("Could not get current track.")
			return

	if AudioPlayer == null:
		#print_debug("Could not find music player to use. Trying again.")
		AudioPlayer = AudioStreamPlayer.new()
		self.add_child(AudioPlayer)
		on_start_track()

func _process(_delta):
	if AudioPlayer != null:
		Global.Master_Volume_Setting = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
		Global.Music_Volume_Setting = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))

func _ready():
	AudioServer.set_bus_layout(AudioBusLayoutOne)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -30)
	Global.Music_Volume_Setting = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))

	self.add_child(AudioPlayer)
	SignalManager.play_track.connect(on_start_track)
	SignalManager.stop_track.connect(on_stop_track)
