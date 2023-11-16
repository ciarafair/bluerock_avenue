extends Node

const Audio_Bus_Layout: String =  "res://resources/audio/default_bus_layout.tres"

var MusicPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
var AudioBusLayoutOne: AudioBusLayout = preload(Audio_Bus_Layout)

const Door_Opening_SFX_Path: String = "res://resources/audio/sound_effects/open_door.mp3"
var Door_Opening_SFX_Instance: AudioStreamMP3 = preload(Door_Opening_SFX_Path)
const Door_Closing_SFX_Path: String = "res://resources/audio/sound_effects/close_door.mp3"
var Door_Closing_SFX_Instance: AudioStreamMP3 = preload(Door_Closing_SFX_Path)
const Window_Opening_SFX_Path: String = "res://resources/audio/sound_effects/open_window.mp3"
var Window_Opening_SFX_Instance: AudioStreamMP3 = preload(Window_Opening_SFX_Path)
const Window_Closing_SFX_Path: String = "res://resources/audio/sound_effects/close_window.mp3"
var Window_Closing_SFX_Instance: AudioStreamMP3 = preload(Window_Closing_SFX_Path)
const Clock_Ticking_SFX_Path: String = "res://resources/audio/sound_effects/clock_ticking.mp3"
var Clock_Ticking_SFX_Instance: AudioStreamMP3 = preload(Clock_Ticking_SFX_Path)

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

func on_music_player_finished():
	if Global.Is_Music_Playing == true:
		Global.Is_Music_Playing = false
		MusicPlayer.stop()
		return

func on_stop_track():
	if MusicPlayer != null and Global.Is_Music_Playing == true:
		#print_debug("Stopping track: " + str(Global.Current_Track))
		Global.Is_Music_Playing = false
		Global.Current_Track = ""
		MusicPlayer.stop()
		return

	if MusicPlayer == null:
		push_error("Could not find music player to kill.")
		return

func on_start_track(track: AudioStreamMP3):
	if MusicPlayer != null and Global.Is_Music_Playing == false:
		MusicPlayer.set_bus("Music")
		MusicPlayer.set_stream(track)
		Global.Is_Music_Playing = true

		if MusicPlayer.stream != null:
			Global.Current_Track = MusicPlayer.stream.resource_name
			#print_debug("Playing track: " +  str(Global.Current_Track))
			MusicPlayer.play()
			return

		if MusicPlayer.stream == null:
			push_warning("Could not get current track.")
			return

	if MusicPlayer == null:
		push_warning("Could not find music player to use. Trying again.")
		on_start_track(track)
		pass

func on_door_open(node):
	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	audio_player.set_stream(Door_Opening_SFX_Instance)
	node.add_child(audio_player)
	audio_player.set_name("OpenSoundEffect")
	audio_player.set_bus("SFX")
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()
	return

func on_door_close(node):
	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	audio_player.set_stream(Door_Closing_SFX_Instance)
	audio_player.set_bus("SFX")
	node.add_child(audio_player)
	audio_player.set_name("CloseSoundEffect")
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()
	return

func on_window_open(node):
	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	audio_player.set_stream(Window_Opening_SFX_Instance)
	node.add_child(audio_player)
	audio_player.set_name("OpenSoundEffect")
	audio_player.set_bus("SFX")
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()
	return

func on_window_close(node, start_point):
	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	audio_player.set_stream(Window_Closing_SFX_Instance)
	audio_player.set_bus("SFX")
	node.add_child(audio_player)
	audio_player.set_name("CloseSoundEffect")
	audio_player.play(start_point)
	await audio_player.finished
	audio_player.queue_free()
	return

func on_clock_ticking(node):
	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	Clock_Ticking_SFX_Instance.set_loop(true)
	audio_player.set_stream(Clock_Ticking_SFX_Instance)
	node.add_child(audio_player)
	audio_player.set_name("ClockTickingSoundEffect")
	audio_player.set_bus("SFX")
	audio_player.set_max_distance(20)
	audio_player.set_volume_db(15)
	audio_player.play()
	return

func setup_audio_server():
	AudioServer.set_bus_layout(AudioBusLayoutOne)
	SignalManager.play_track.connect(Callable(on_start_track))
	SignalManager.stop_track.connect(Callable(on_stop_track))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), Global.Settings_Data_Instance.Master_Volume_Setting)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.Settings_Data_Instance.Music_Volume_Setting)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.Settings_Data_Instance.SFX_Volume_Setting)
	return

func _process(_delta):
	if MusicPlayer != null:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), Global.Settings_Data_Instance.Master_Volume_Setting)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.Settings_Data_Instance.Music_Volume_Setting)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.Settings_Data_Instance.SFX_Volume_Setting)
	if MusicPlayer == null:
		setup_audio_server()

func manage_signals():
	SignalManager.door_open_sound.connect(Callable(on_door_open))
	SignalManager.door_close_sound.connect(Callable(on_door_close))
	SignalManager.window_open_sound.connect(Callable(on_window_open))
	SignalManager.window_close_sound.connect(Callable(on_window_close))
	SignalManager.clock_ticking.connect(Callable(on_clock_ticking))
	return

func _ready():
	manage_signals()
	self.add_child(MusicPlayer)
	setup_audio_server()
	return
