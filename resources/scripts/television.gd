extends LocationBlock
class_name TelevisionBlock

@onready var ScreenMesh: MeshInstance3D = %Screen
@onready var AspectRatio: AspectRatioContainer = %AspectRatioContainer
@onready var ScreenTexture = load("res://resources/textures/television_viewport_texture.tres")

var VideoPlayerInstance: VideoStreamPlayer
var AudioPlayerInstance: AudioStreamPlayer3D
var VideoCurrentTime: float = 0

func on_toggle_tv():
	Global.Game_Data_Instance.Television_State = !Global.Game_Data_Instance.Television_State
	manage_televison()
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
	video_player.set_paused(true)
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
	audio_player.set_stream_paused(true)
	audio_player.set_max_distance(20)
	#print_debug("Adding audio player")
	AudioPlayerInstance = audio_player
	return AudioPlayerInstance

func manage_television_audio():
	if Global.Game_Data_Instance.Television_State == true:
		if AudioPlayerInstance != null:
			if AudioPlayerInstance.playing == false:
				#print_debug("Playing audio.")
				AudioPlayerInstance.set_stream_paused(false)
				AudioPlayerInstance.play()
				return
			return
		AspectRatio.add_child(setup_audio_player())
		manage_television_audio()
		return

	if AudioPlayerInstance != null:
		#print_debug("Stopping audio.")
		AudioPlayerInstance.queue_free()
		return
	return


func manage_television_video():
	if Global.Game_Data_Instance.Television_State == true:
		if VideoPlayerInstance != null:
			if VideoPlayerInstance.is_playing() == false:
				#print_debug("Playing video.")
				VideoPlayerInstance.set_paused(false)
				VideoPlayerInstance.play()
				return

		#print_debug("Creating new video player.")
		AspectRatio.add_child(setup_video_player())
		#VideoPlayerInstance.set_stream_position(VideoCurrentTime)
		manage_television_video()
		return

	if VideoPlayerInstance != null:
		#print_debug("Stopping video.")
		VideoPlayerInstance.queue_free()
		return
	return


func manage_televison():
	manage_television_audio()
	manage_television_video()
	return

func manage_signals():
	SignalManager.toggle_tv.connect(Callable(on_toggle_tv))

func _ready():
	block_ready()
	manage_signals()
	set_process(true)
	await SignalManager.game_world_loaded
	if Global.Game_Data_Instance.Television_State == true:
		manage_televison()

func _process(_delta):
	pass
#	if VideoPlayerInstance != null:
#		VideoCurrentTime = VideoPlayerInstance.get_stream_position()
