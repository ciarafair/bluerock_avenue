extends Node

const Audio_Bus_Layout: String =  "res://resources/audio/default_bus_layout.tres"

var MusicPlayerInstance: AudioStreamPlayer = AudioStreamPlayer.new()
var AudioBusLayoutOne: AudioBusLayout = load(Audio_Bus_Layout)

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

func on_music_player_finished():
	if Global.Is_Music_Playing == true:
		Global.Is_Music_Playing = false
		MusicPlayerInstance.stop()
		return

func on_stop_track():
	if MusicPlayerInstance != null and Global.Is_Music_Playing == true:
		#print_rich("Stopping track: %s" %[str(Global.Current_Track)])
		#Global.stack_info(get_stack())
		Global.Is_Music_Playing = false
		Global.Current_Track = ""
		MusicPlayerInstance.stop()
		return

	if MusicPlayerInstance == null:
		#printerr("Could not find music player to kill.")
		#Global.stack_info(get_stack())
		return

func on_start_track(track: AudioStreamMP3):
	if MusicPlayerInstance != null and Global.Is_Music_Playing == false:
		MusicPlayerInstance.set_bus("Music")
		track.set_loop(true)
		track.set_loop_offset(0.0)
		MusicPlayerInstance.set_stream(track)
		Global.Is_Music_Playing = true

		if MusicPlayerInstance.stream != null:
			Global.Current_Track = MusicPlayerInstance.stream.resource_name
			#print_rich("Playing track: %s" %[str(Global.Current_Track)])
			#Global.stack_info(get_stack())
			MusicPlayerInstance.play()
			return

		if MusicPlayerInstance.stream == null:
			printerr("Could not get current track.")
			Global.stack_info(get_stack())
			return

	if MusicPlayerInstance == null:
		printerr("Could not find music player to use. Trying again.")
		Global.stack_info(get_stack())
		on_start_track(track)
		pass

func on_door_open(_node):
#	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
#	audio_player.set_stream(Door_Opening_SFX_Instance)
#	node.add_child(audio_player)
#	audio_player.set_name("OpenSoundEffect")
#	audio_player.set_bus("SFX")
#	audio_player.play()
#	await audio_player.finished
#	audio_player.queue_free()
	return

func on_door_close(_node):
#	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
#	audio_player.set_stream(Door_Closing_SFX_Instance)
#	audio_player.set_bus("SFX")
#	node.add_child(audio_player)
#	audio_player.set_name("CloseSoundEffect")
#	audio_player.play()
#	await audio_player.finished
#	audio_player.queue_free()
	return

func on_window_open(_node):
#	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
#	audio_player.set_stream(Window_Opening_SFX_Instance)
#	node.add_child(audio_player)
#	audio_player.set_name("OpenSoundEffect")
#	audio_player.set_bus("SFX")
#	audio_player.play()
#	await audio_player.finished
#	audio_player.queue_free()
	return

func on_window_close(_node, _start_point):
#	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
#	audio_player.set_stream(Window_Closing_SFX_Instance)
#	audio_player.set_bus("SFX")
#	node.add_child(audio_player)
#	audio_player.set_name("CloseSoundEffect")
#	audio_player.play(start_point)
#	await audio_player.finished
#	audio_player.queue_free()
	return


const Clock_Ticking_SFX_Path: String = "res://resources/audio/sound_effects/clock_ticking.mp3"
var Clock_Ticking_SFX_Instance: AudioStreamMP3 = load(Clock_Ticking_SFX_Path)

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
	if MusicPlayerInstance != null:
		MusicPlayerInstance.queue_free()
	MusicPlayerInstance = AudioStreamPlayer.new()
	self.add_child(MusicPlayerInstance)

	AudioServer.set_bus_layout(AudioBusLayoutOne)
	SignalManager.play_track.connect(Callable(on_start_track))
	SignalManager.stop_track.connect(Callable(on_stop_track))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), Global.Settings_Data_Instance.Master_Volume_Setting)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.Settings_Data_Instance.Music_Volume_Setting)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.Settings_Data_Instance.SFX_Volume_Setting)
	return

func _process(_delta):
	if MusicPlayerInstance != null:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), Global.Settings_Data_Instance.Master_Volume_Setting)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.Settings_Data_Instance.Music_Volume_Setting)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.Settings_Data_Instance.SFX_Volume_Setting)
	if MusicPlayerInstance == null:
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
	setup_audio_server()
	return
