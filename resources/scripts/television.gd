extends LocationBlock

@onready var ScreenMesh: MeshInstance3D = %Screen
@onready var VideoContainer: AspectRatioContainer = %AspectRatioContainer
@onready var ScreenTexture = load("res://resources/textures/television_viewport_texture.tres")

var VideoPlayerInstance: VideoStreamPlayer
var AudioPlayerInstance: AudioStreamPlayer3D
var VideoCurrentTime: float = 0

func on_toggle_tv():
	if Global.Game_Data_Instance.Current_Task == Global.task.TURN_OFF_TV:
		Global.Game_Data_Instance.Current_Task = Global.task.EXPLORE
		#print_debug(Global.Game_Data_Instance.Current_Task)
	Global.Game_Data_Instance.Television_State = !Global.Game_Data_Instance.Television_State
	#print_debug("Toggling the television to %s" %[Global.Game_Data_Instance.Television_State])

func setup_video_player():
	var video = preload(Path.StockCartoonVideoPath)
	var video_player: VideoStreamPlayer
	video_player = VideoStreamPlayer.new()
	video_player.set_name("CartoonVideo")
	video_player.set_bus("SFX")
	video_player.set_stream(video)
	video_player.set_autoplay(false)
	video_player.set_expand(true)
	video_player.set_paused(false)
	video_player.set_volume_db(-80)
	#print_debug("Adding video player")
	VideoPlayerInstance = video_player
	return VideoPlayerInstance

func setup_audio_player():
	var audio: AudioStreamMP3 = load(Path.StockCartoonAudioPath)
	var audio_player: AudioStreamPlayer3D
	audio_player = AudioStreamPlayer3D.new()
	audio_player.set_name("CartoonAudio")
	audio_player.set_bus("SFX")
	audio_player.set_stream(audio)
	audio_player.set_autoplay(false)
	audio_player.set_stream_paused(false)
	audio_player.set_max_distance(20)
	#print_debug("Adding audio player")
	AudioPlayerInstance = audio_player
	return AudioPlayerInstance

func manage_televison():
	if AudioPlayerInstance != null:
		if Global.Game_Data_Instance.Television_State == false:
			if AudioPlayerInstance.is_playing():
				#print_debug("Stopping audio.")
				AudioPlayerInstance.queue_free()
				return

		if Global.Game_Data_Instance.Television_State == true:
			if !AudioPlayerInstance.is_playing():
				#print_debug("Playing audio.")
				AudioPlayerInstance.play()
				return

	if VideoPlayerInstance != null:
		if Global.Game_Data_Instance.Television_State == false:
			if VideoPlayerInstance.is_playing():
				#print_debug("Stopping video.")
				VideoPlayerInstance.queue_free()
				return

		if Global.Game_Data_Instance.Television_State == true:
			if !VideoPlayerInstance.is_playing():
				#print_debug("Playing video.")
				VideoPlayerInstance.play()
				return

	if AudioPlayerInstance == null:
		if Global.Game_Data_Instance.Television_State == true:
			VideoContainer.add_child(setup_audio_player())
			AudioPlayerInstance.play()
			return

	if VideoPlayerInstance == null:
		if Global.Game_Data_Instance.Television_State == true:
			VideoContainer.add_child(setup_video_player())
			#VideoPlayerInstance.set_stream_position(VideoCurrentTime)
			VideoPlayerInstance.play()
			return
	return

func manage_signals():
	SignalManager.toggle_tv.connect(Callable(on_toggle_tv))

func _ready():
	VideoContainer.add_child(setup_audio_player())
	VideoContainer.add_child(setup_video_player())
	AudioPlayerInstance.play()
	VideoPlayerInstance.play()
	manage_televison()
	block_ready()

	SignalManager.television_cartoon.emit(VideoPlayerInstance, true, VideoCurrentTime)
	manage_signals()
	set_process(true)

func _process(_delta):
	manage_televison()
	if VideoPlayerInstance != null:
		VideoCurrentTime = VideoPlayerInstance.get_stream_position()
