extends Node

@export var Skip_Main_Menu: bool = false

var Audio_Manager_Instance = preload(Global.Audio_Manager_Path).instantiate()

var Game_World_Instance = preload(Global.Game_World_Path).instantiate()
var Bedroom_Instance = preload(Global.Bedroom_Path).instantiate()
var Hallway_Instance = preload(Global.Hallway_Path).instantiate()
var Player_Instance = preload(Global.Player_Path).instantiate()
var Scene_Lighting_Instance = preload(Global.Scene_Lighting_Path).instantiate()

var Dev_Utilities_Instance = preload(Global.Dev_Utilities_Path).instantiate()
var User_Interface_Instance = preload(Global.User_Interface_Path).instantiate()
var Movement_Interface_Instance = preload(Global.Movement_Interface_Path).instantiate()
var Main_Menu_Instance = preload(Global.Main_Menu_Path).instantiate()
var Main_Menu_Aniamtion_Instance = preload(Global.Main_Menu_Animation_Path).instantiate()
var Pause_Menu_Instance = preload(Global.Pause_Menu_Path).instantiate()
var Options_Menu_Instance = preload(Global.Options_Menu_Path).instantiate()

func add_pause_menu():
	if Pause_Menu_Instance == null:
		print_debug("Could not find pause menu instance. Trying again.")
		Pause_Menu_Instance = preload(Global.Pause_Menu_Path).instantiate()

	User_Interface_Instance.add_child(Pause_Menu_Instance)

func add_options_menu():
	if Options_Menu_Instance == null:
		print_debug("Could not find pause menu instance. Trying again.")
		Options_Menu_Instance = preload(Global.Options_Menu_Path).instantiate()

	User_Interface_Instance.add_child(Options_Menu_Instance)

func add_movement_interface():
	if Movement_Interface_Instance == null:
		print_debug("Could not find player instance. Trying again.")
		Movement_Interface_Instance = preload(Global.Movement_Interface_Path).instantiate()

	User_Interface_Instance.add_child(Movement_Interface_Instance)

func add_player():
	if Player_Instance == null:
		print_debug("Could not find player instance. Trying again.")
		Player_Instance = preload(Global.Player_Path).instantiate()

	Game_World_Instance.add_child(Player_Instance)

func on_load_bedroom():
	if Bedroom_Instance == null:
		print_debug("Could not find bedroom instance. Trying again.")
		Bedroom_Instance = preload(Global.Bedroom_Path).instantiate()
	else:
		Game_World_Instance.add_child(Bedroom_Instance)

func on_load_hallway():
	if Hallway_Instance == null:
		print_debug("Could not find hallway instance. Trying again.")
		Hallway_Instance = preload(Global.Hallway_Path).instantiate()
	else:
		Game_World_Instance.add_child(Hallway_Instance)

func on_room_loaded(_node):
	if Global.Current_Room == _node:
		print_debug(str(_node.name) + " is already the current room.")
	else:
		print_debug("Setting " + str(_node.name) + " as current room")
		Global.Current_Room = _node

func load_user_interface():
	self.add_child(User_Interface_Instance)
	User_Interface_Instance.add_child(Dev_Utilities_Instance)

func on_load_game_world():
	if Game_World_Instance != null:
		self.add_child(Game_World_Instance)
		add_player()
		add_pause_menu()
		add_movement_interface()
		return

	if Game_World_Instance == null:
		#print_debug("Could not find game world instance. Trying again.")
		Game_World_Instance = preload(Global.Game_World_Path).instantiate()
		on_load_game_world()

func on_game_world_loaded():
	print_debug("Game world was loaded.")
	Global.Is_Pause_Menu_Open = false
	if Main_Menu_Instance != null:
		Main_Menu_Instance.queue_free()

func on_load_main_menu():
	print_debug("Loading main menu.")
	if Main_Menu_Instance != null:
		User_Interface_Instance.add_child(Main_Menu_Instance)

	if Main_Menu_Aniamtion_Instance != null:
		self.add_child(Main_Menu_Aniamtion_Instance)
	else:
		Main_Menu_Aniamtion_Instance = preload(Global.Main_Menu_Animation_Path).instantiate()

	if Main_Menu_Instance == null:
		print_debug("Could not find main menu. Trying again.")
		Main_Menu_Instance = preload(Global.Main_Menu_Path).instantiate()
		on_load_main_menu()

func on_main_menu_loaded():
	print_debug("Main menu was loaded.")
	get_tree().paused = false
	if Game_World_Instance != null:
		Game_World_Instance.queue_free()
	if Pause_Menu_Instance != null:
		Pause_Menu_Instance.queue_free()
	if Movement_Interface_Instance != null:
		Movement_Interface_Instance.queue_free()
	if Options_Menu_Instance != null:
		Options_Menu_Instance.queue_free()

func on_load_pause_menu():
	if Pause_Menu_Instance != null:
		User_Interface_Instance.add_child(Pause_Menu_Instance)
		return

	if Pause_Menu_Instance == null:
		print_debug("Could not find pause menu. Trying again.")
		Pause_Menu_Instance = preload(Global.Pause_Menu_Path).instantiate()
		on_load_pause_menu()

func on_pause_menu_loaded():
	if Options_Menu_Instance != null:
		Options_Menu_Instance.queue_free()

func on_load_options_menu():
	if Options_Menu_Instance != null:
		User_Interface_Instance.add_child(Options_Menu_Instance)
		return

	if Options_Menu_Instance == null:
		print_debug("Could not find options menu. Trying again.")
		Options_Menu_Instance = preload(Global.Options_Menu_Path).instantiate()
		on_load_options_menu()

func on_options_menu_loaded():
	print_debug("Options menu was loaded.")
	if Main_Menu_Instance != null:
		Main_Menu_Instance.queue_free()
	if Pause_Menu_Instance != null:
		Pause_Menu_Instance.queue_free()

func on_exit_options_menu():
	if Global.Is_Game_Active == true:
		SignalManager.load_pause_menu.emit()

	if Global.Is_Game_Active != true:
		SignalManager.load_main_menu.emit()

func load_audio_manager():
	if Audio_Manager_Instance == null:
		Audio_Manager_Instance = preload(Global.Audio_Manager_Path).instantiate()
	else:
		print_debug("Audio manager loaded.")
		self.add_child(Audio_Manager_Instance)

func _process(_delta):
	if Global.Is_Game_Active == true:
		if Main_Menu_Aniamtion_Instance != null:
			Main_Menu_Aniamtion_Instance.queue_free()

		if User_Interface_Instance == null:
			User_Interface_Instance.add_child(Movement_Interface_Instance)

func _ready():
	SignalManager.load_game_world.connect(on_load_game_world)
	SignalManager.game_world_loaded.connect(on_game_world_loaded)

	SignalManager.load_pause_menu.connect(on_load_pause_menu)
	SignalManager.pause_menu_loaded.connect(on_pause_menu_loaded)

	SignalManager.load_options_menu.connect(on_load_options_menu)
	SignalManager.options_menu_loaded.connect(on_options_menu_loaded)
	SignalManager.exit_options_menu.connect(on_exit_options_menu)

	SignalManager.load_main_menu.connect(on_load_main_menu)
	SignalManager.main_menu_loaded.connect(on_main_menu_loaded)

	SignalManager.room_loaded.connect(on_room_loaded)
	SignalManager.load_bedroom.connect(on_load_bedroom)
	SignalManager.load_hallway.connect(on_load_hallway)

	load_audio_manager()
	load_user_interface()

	if Skip_Main_Menu == true:
		SignalManager.load_game_world.emit()

	if Skip_Main_Menu != true:
		SignalManager.load_main_menu.emit()
