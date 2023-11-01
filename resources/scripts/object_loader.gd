extends Node

@export var Skip_Main_Menu: bool = false

const AudioManagerPath: String = "res://resources/scenes/audio_manager.tscn"

const GameWorldPath: String = "res://resources/scenes/game_world/game_world.tscn"
const PlayerPath: String = "res://resources/scenes/game_world/player.tscn"
const MonsterPath: String = "res://resources/scenes/game_world/monster.tscn"

const PauseMenuPath: String = "res://resources/scenes/user_interface/pause_menu.tscn"
const OptionsMenuPath: String = "res://resources/scenes/user_interface/options_menu.tscn"
const GameOverScreenPath: String = "res://resources/scenes/user_interface/game_over_screen.tscn"
const MainMenuPath: String = "res://resources/scenes/user_interface/main_menu.tscn"
const MovementInterfacePath: String = "res://resources/scenes/user_interface/movement_interface.tscn"
const DevUtilitiesPath: String = "res://resources/scenes/user_interface/developer_utilities.tscn"

# Audio
var Audio_Manager_Instance = preload(AudioManagerPath).instantiate()

# Game World
var Game_World_Instance = preload(GameWorldPath).instantiate()
var Player_Instance = preload(PlayerPath).instantiate()
var Monster_Instance = preload(MonsterPath).instantiate()

# User Interface
var User_Interface_Instance = Control.new()

var Dev_Utilities_Instance = preload(DevUtilitiesPath).instantiate()
var Movement_Interface_Instance = preload(MovementInterfacePath).instantiate()
var Main_Menu_Instance = preload(MainMenuPath).instantiate()
var Pause_Menu_Instance = preload(PauseMenuPath).instantiate()
var Options_Menu_Instance = preload(OptionsMenuPath).instantiate()
var Game_Over_Screen_Instance = preload(GameOverScreenPath).instantiate()

func add_pause_menu():
	if Pause_Menu_Instance == null:
		#print_debug("Could not find pause menu instance. Trying again.")
		Pause_Menu_Instance = preload(PauseMenuPath).instantiate()
		add_pause_menu()
	else:
		User_Interface_Instance.add_child(Pause_Menu_Instance)

func add_game_over_screen():
	if Game_Over_Screen_Instance == null:
		#print_debug("Could not find game over instance. Trying again.")
		Game_Over_Screen_Instance = preload(GameOverScreenPath).instantiate()
		add_game_over_screen()
	else:
		User_Interface_Instance.add_child(Game_Over_Screen_Instance)

func add_options_menu():
	if Options_Menu_Instance == null:
	#	print_debug("Could not find pause menu instance. Trying again.")
		Options_Menu_Instance = preload(OptionsMenuPath).instantiate()
		add_options_menu()
	else:
		User_Interface_Instance.add_child(Options_Menu_Instance)

func add_movement_interface():
	if Movement_Interface_Instance == null:
	#	print_debug("Could not find player instance. Trying again.")
		Movement_Interface_Instance = preload(MovementInterfacePath).instantiate()
		add_movement_interface()
	else:
		User_Interface_Instance.add_child(Movement_Interface_Instance)

func add_player():
	if Player_Instance == null:
		#print_debug("Could not find player instance. Trying again.")
		Player_Instance = preload(PlayerPath).instantiate()
		add_player()
	else:
		Game_World_Instance.add_child(Player_Instance)

func add_monster():
	if Monster_Instance == null:
		#print_debug("Could not find player instance. Trying again.")
		Monster_Instance = preload(MonsterPath).instantiate()
		add_monster()
	else:
		Game_World_Instance.add_child(Monster_Instance)

func on_room_loaded(_node):
	if Global.Current_Room == _node:
		#print_debug(str(_node.name) + " is already the current room.")
		pass
	else:
		#print_debug("Setting " + str(_node.name) + " as current room")
		Global.Current_Room = _node

func load_user_interface():
	User_Interface_Instance.name = "UserInterface"
	self.add_child(User_Interface_Instance)
	User_Interface_Instance.add_child(Dev_Utilities_Instance)

func on_load_game_world():
	if Game_World_Instance != null:
		self.add_child(Game_World_Instance)
		add_player()
		add_monster()
		add_pause_menu()
		add_movement_interface()
		add_game_over_screen()
		return

	if Game_World_Instance == null:
		#print_debug("Could not find game world instance. Trying again.")
		Game_World_Instance = preload(GameWorldPath).instantiate()
		on_load_game_world()

func on_game_world_loaded():
	#print_debug("Game world was loaded.")
	Global.Is_Pause_Menu_Open = false
	if Main_Menu_Instance != null:
		Main_Menu_Instance.queue_free()

func on_load_main_menu():
	#print_debug("Loading main menu.")
	if Main_Menu_Instance != null:
		User_Interface_Instance.add_child(Main_Menu_Instance)
	if Main_Menu_Instance == null:
		#print_debug("Could not find main menu. Trying again.")
		Main_Menu_Instance = preload(MainMenuPath).instantiate()
		on_load_main_menu()

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

func on_load_pause_menu():
	if Pause_Menu_Instance != null:
		User_Interface_Instance.add_child(Pause_Menu_Instance)
		return

	if Pause_Menu_Instance == null:
		#print_debug("Could not find pause menu. Trying again.")
		Pause_Menu_Instance = preload(PauseMenuPath).instantiate()
		on_load_pause_menu()

func on_pause_menu_loaded():
	if Options_Menu_Instance != null:
		Options_Menu_Instance.queue_free()

func on_load_options_menu():
	if Options_Menu_Instance != null:
		User_Interface_Instance.add_child(Options_Menu_Instance)
		return

	if Options_Menu_Instance == null:
		#print_debug("Could not find options menu. Trying again.")
		Options_Menu_Instance = preload(OptionsMenuPath).instantiate()
		on_load_options_menu()

func on_options_menu_loaded():
	#print_debug("Options menu was loaded.")
	if Main_Menu_Instance != null:
		Main_Menu_Instance.queue_free()
	if Pause_Menu_Instance != null:
		Pause_Menu_Instance.queue_free()

func on_exit_options_menu():
	if Global.Is_Game_Active == true:
		SignalManager.load_pause_menu.emit()
	else:
		SignalManager.load_main_menu.emit()

func load_audio_manager():
	if Audio_Manager_Instance == null:
		Audio_Manager_Instance = preload(AudioManagerPath).instantiate()
	else:
		#print_debug("Audio manager loaded.")
		self.add_child(Audio_Manager_Instance)

func on_set_monster_position(_node):
	Monster_Instance.position = _node.position + Global.Monster_Current_Room.position
	#print_debug("Monster's position: " + str(Monster_Instance.position) + " should equal the set position of " + str(_node.position))
	Monster_Instance.rotation = _node.rotation + Global.Monster_Current_Room.rotation
	#print_debug("Monster's rotation: " + str(Monster_Instance.rotation) + " should equal the set rotation of " + str(_node.rotation))

func _process(_delta):
	if User_Interface_Instance == null:
		User_Interface_Instance.add_child(Movement_Interface_Instance)
		return
	else:
		pass

func manage_signals_on_start():
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
	SignalManager.set_monster_position.connect(on_set_monster_position)

func _ready():
	manage_signals_on_start()
	load_audio_manager()
	load_user_interface()

	if Skip_Main_Menu == true:
		SignalManager.load_game_world.emit()
		return

	if Skip_Main_Menu != true:
		SignalManager.load_main_menu.emit()
		return
