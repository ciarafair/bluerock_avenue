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
		push_warning("%s instance already exists."%[node_instance])
		add_object(node_path, node_instance, parent_instance)
	node_instance = load(str(node_path)).instantiate()
	parent_instance.add_child(node_instance)

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

func delete_game_world():
	print_debug("Game world freed.")
	Global.Loaded_Game_World.queue_free()
	return

func on_load_game_world():
	Game_World_Instance = preload(Path.GameWorldPath).instantiate()
	self.add_child(Game_World_Instance)
	if Global.Game_Data.Is_Monster_Active == true:
		add_object(Path.MonsterPath, Monster_Instance, Game_World_Instance)
	add_object(Path.PlayerPath, Player_Instance, Game_World_Instance)
	add_object(Path.PauseMenuPath, Player_Instance, User_Interface_Instance)
	add_object(Path.MovementInterfacePath, Movement_Interface_Instance, User_Interface_Instance)
	add_object(Path.GameOverScreenPath, Game_Over_Screen_Instance, User_Interface_Instance)
	Global.load_data(Global.Game_File_Path, "game")
	return

func on_game_world_loaded():
	print_debug("Game world loaded.")
	if Global.Loaded_Main_Menu:
		delete_main_menu()

func delete_main_menu():
	print_debug("Main menu freed.")
	Global.Loaded_Main_Menu.queue_free()
	return

func on_main_menu_loaded():
	print_debug("Main menu was loaded.")
	if Global.Loaded_Game_World:
		delete_game_world()
	get_tree().paused = false

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

	SignalManager.game_world_loaded.connect(Callable(on_game_world_loaded))
	SignalManager.main_menu_loaded.connect(Callable(on_main_menu_loaded))

	SignalManager.pause_menu_loaded.connect(on_pause_menu_loaded)
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
