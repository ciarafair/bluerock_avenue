extends Node

signal progress_changed(progress)
signal load_done

var Load_Screen = preload(Path.LoadingScreenPath)
var Loaded_Resource: PackedScene
var Scene_Path: String
var ProgressMade: Array = []
var UseSubThreads: bool = true

func load_scene(path: String):
	Scene_Path = path
	var Load_Screen_Instance = Load_Screen.instantiate()
	Global.Loaded_User_Interface.add_child(Load_Screen_Instance)

	self.progress_changed.connect(Callable(Load_Screen_Instance.update_progress_bar))
	self.load_done.connect(Callable(Load_Screen_Instance.start_exit_animation))

	await Signal(Load_Screen_Instance, "loading_screen_has_full_coverage")
	start_load()

func start_load():
	var state = ResourceLoader.load_threaded_request(Scene_Path, "", UseSubThreads)
	if state == OK:
		set_process(true)

func _process(_delta):
	var load_status = ResourceLoader.load_threaded_get_status(Scene_Path, ProgressMade)
	match load_status:
		0, 2: #? THREAD_LOAD_INVALID_RESOURCE, THREAD_LOAD_FAILED
			set_process(false)
			#printerr(load_status)
			return
		1: #? THREAD_LOAD_IN_PROGRESS
			#print_debug("Loading scene %s: %s percent." %[Scene_Path, ProgressMade[0]])
			emit_signal("progress_changed", ProgressMade[0])
		3: #? THREAD_LOAD_LOADED
			#print_debug("Loading scene %s completed." %[Scene_Path])
			Loaded_Resource = ResourceLoader.load_threaded_get(Scene_Path)
			emit_signal("progress_changed", 1.0)
			emit_signal("load_done")
			SignalManager.scene_loaded.emit(Loaded_Resource)
