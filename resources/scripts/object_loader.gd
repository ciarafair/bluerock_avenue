extends Node

@export var Skip_Main_Menu: bool = false

# Audio
var Audio_Manager_Instance

# Game World
var Game_World_Instance
var Player_Instance
var Monster_Instance

# User Interface
var User_Interface_Instance = Control.new()

var Dev_Utilities_Instance
var Movement_Interface_Instance
var Main_Menu_Instance
var Pause_Menu_Instance
var Options_Menu_Instance
var Game_Over_Screen_Instance

func check_if_exists(node, parent):
	for child in parent.get_children(true):
		if child == node:
			push_warning("%s instance already exists."%[child.name])
			return true

func add_object(node_path, node_instance, parent_instance):
	if check_if_exists(node_instance, parent_instance):
		node_instance.queue_free()
		add_object(node_path, node_instance, parent_instance)
		return
	node_instance = load(str(node_path)).instantiate()
	parent_instance.add_child(node_instance)

func add_pause_menu():
	if check_if_exists(Main_Menu_Instance, User_Interface_Instance):
		return
	Pause_Menu_Instance = preload(Path.PauseMenuPath).instantiate()
	User_Interface_Instance.add_child(Pause_Menu_Instance)

func add_game_over_screen():
	if check_if_exists(Game_Over_Screen_Instance, User_Interface_Instance):
		return
	Game_Over_Screen_Instance = preload(Path.GameOverScreenPath).instantiate()
	User_Interface_Instance.add_child(Game_Over_Screen_Instance)
	return

func add_options_menu():
	if check_if_exists(Options_Menu_Instance, User_Interface_Instance):
		return
	Options_Menu_Instance = preload(Path.OptionsMenuPath).instantiate()
	User_Interface_Instance.add_child(Options_Menu_Instance)
	return


func on_room_loaded(node):
	if Global.Game_Data.Current_Room == node:
		#print_debug(str(_node.name) + " is already the current room.")
		pass
	else:
		#print_debug("Setting " + str(_node.name) + " as current room")
		Global.Game_Data.Current_Room = node

func load_user_interface():
	User_Interface_Instance.name = "UserInterface"
	self.add_child(User_Interface_Instance)
	add_object(Path.DevUtilitiesPath, Dev_Utilities_Instance, User_Interface_Instance)
	add_object(Path.OptionsMenuPath, Options_Menu_Instance, User_Interface_Instance)

func on_free_game_world():
	if Game_World_Instance != null:
		Game_World_Instance.queue_free()
		await Game_World_Instance.tree_exited

func on_load_game_world():
	if Game_World_Instance != null:
		self.add_child(Game_World_Instance)
		if Global.Game_Data.Is_Monster_Active == true:
			add_object(Path.MonsterPath, Monster_Instance, Game_World_Instance)
		else:
			pass
		add_object(Path.PlayerPath, Player_Instance, Game_World_Instance)
		add_object(Path.PauseMenuPath, Player_Instance, User_Interface_Instance)
		add_object(Path.MovementInterfacePath, Movement_Interface_Instance, User_Interface_Instance)
		add_object(Path.GameOverScreenPath, Game_Over_Screen_Instance, User_Interface_Instance)
		return

	if Game_World_Instance == null:
		#print_debug("Could not find game world instance. Trying again.")
		Game_World_Instance = preload(Path.GameWorldPath).instantiate()
		on_load_game_world()

func on_main_menu_loaded():
	#print_debug("Main menu was loaded.")
	get_tree().paused = false
	if Game_World_Instance != null:
		Game_World_Instance.queue_free()
	if Pause_Menu_Instance != null:
		Pause_Menu_Instance.queue_free()
	if Movement_Interface_Instance != null:
		Movement_Interface_Instance.queue_free()
	if Options_Menu_Instance != null:
		Options_Menu_Instance.queue_free()

func on_pause_menu_loaded():
	if Options_Menu_Instance != null:
		Options_Menu_Instance.queue_free()

func on_load_options_menu():
	if Options_Menu_Instance != null:
		User_Interface_Instance.add_child(Options_Menu_Instance)
		return

	if Options_Menu_Instance == null:
		push_error("Could not find options menu. Trying again.")
		Options_Menu_Instance = preload(Path.OptionsMenuPath).instantiate()
		on_load_options_menu()

func on_options_menu_loaded():
	#print_debug("Options menu was loaded.")
	if Main_Menu_Instance != null:
		Main_Menu_Instance.queue_free()
	if Pause_Menu_Instance != null:
		Pause_Menu_Instance.queue_free()

func on_exit_options_menu():
	if Global.Is_Game_Active == true:
		SignalManager.show_pause_menu.emit()
		return
	else:
		SignalManager.show_main_menu.emit()
		return

func _process(_delta):
	Global.MousePosition2D = get_viewport().get_mouse_position()

	if User_Interface_Instance == null:
		User_Interface_Instance.add_child(Movement_Interface_Instance)
		return
	else:
		pass

func manage_signals():
	SignalManager.load_audio_manager.connect(Callable(add_object).bind(Path.AudioManagerPath, Audio_Manager_Instance, self))
	SignalManager.load_game_world.connect(on_load_game_world)
	SignalManager.load_main_menu.connect(Callable(add_object).bind(Path.MainMenuPath, Main_Menu_Instance, User_Interface_Instance))

	SignalManager.load_player.connect(Callable(add_object).bind(Path.PlayerPath, Player_Instance, Game_World_Instance))
	SignalManager.load_monster.connect(Callable(add_object).bind(Path.MonsterPath, Monster_Instance, Game_World_Instance))
	SignalManager.load_pause_menu.connect(Callable(add_object).bind(Path.PauseMenuPath, Pause_Menu_Instance, User_Interface_Instance))
	SignalManager.load_options_menu.connect(Callable(add_object).bind(Path.OptionsMenuPath, Options_Menu_Instance, User_Interface_Instance))

	SignalManager.free_game_world.connect(on_free_game_world)
	SignalManager.pause_menu_loaded.connect(on_pause_menu_loaded)
	SignalManager.options_menu_loaded.connect(on_options_menu_loaded)
	SignalManager.exit_options_menu.connect(on_exit_options_menu)
	SignalManager.room_loaded.connect(on_room_loaded)

func _ready():
	manage_signals()
	SignalManager.load_audio_manager.emit()
	load_user_interface()

	if Skip_Main_Menu == true:
		SignalManager.load_game_world.emit()
		return

	if Skip_Main_Menu != true:
		SignalManager.load_main_menu.emit()
		return
