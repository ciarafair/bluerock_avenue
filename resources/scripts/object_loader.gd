extends SubViewport

# Audio
var Audio_Manager_Instance

# Game World
var Game_World_Instance
var Local_Player_Instance
var Local_Monster_Instance

# User Interface
var User_Interface_Instance = Control.new()
var Intro_Animation_Instance
var Dev_Utilities_Instance
var Movement_Interface_Instance
var Main_Menu_Instance
var Pause_Menu_Instance
var Options_Menu_Instance
var Game_Over_Screen_Instance
var Dialogue_Box_Instance
var Task_List_Instance
var Popup_Instance

func add_object(node_path: String, node_instance: Node, parent_instance: Node) -> Node:
	if node_instance:
		node_instance.queue_free()
	node_instance = load(str(node_path)).instantiate()
	if parent_instance == null:
		printerr("%s's parent was null. Aborting." %[node_path])
		return null
	parent_instance.add_child(node_instance)
	#print_rich(node_instance)
	#Global.stack_info(get_stack())
	return node_instance

func on_room_loaded(node):
	if Global.Game_Data_Instance.Current_Room == node:
		#print_rich(str(_node.name) + " is already the current room.")
		#Global.stack_info(get_stack())
		pass
	else:
		#print_rich("Setting " + str(_node.name) + " as current room")
		#Global.stack_info(get_stack())
		Global.Game_Data_Instance.Current_Room = node

func load_user_interface():
	User_Interface_Instance.name = "UserInterface"
	self.add_child(User_Interface_Instance)
	Global.Loaded_User_Interface = User_Interface_Instance
	SignalManager.add_overlay_effect.emit()
	add_object(Path.DevUtilitiesPath, Dev_Utilities_Instance, User_Interface_Instance)
	add_object(Path.OptionsMenuPath, Options_Menu_Instance, User_Interface_Instance)

func on_game_world_loaded():
	#print_rich("Game world loaded.")
	#Global.stack_info(get_stack())
	if Global.Loaded_Main_Menu != null:
		Global.Loaded_Main_Menu.queue_free()
		return

func on_main_menu_loaded():
	#print_rich("Main menu was loaded.")
	#Global.stack_info(get_stack())
	if Global.Loaded_Game_World != null:
		Global.Loaded_Game_World.queue_free()
	get_tree().paused = false

func on_load_options_menu():
	if Options_Menu_Instance != null:
		User_Interface_Instance.add_child(Options_Menu_Instance)
		return

	if Options_Menu_Instance == null:
		printerr("Could not find options menu. Trying again.")
		Global.stack_info(get_stack())
		Options_Menu_Instance = preload(Path.OptionsMenuPath).instantiate()
		on_load_options_menu()

func on_exit_options_menu():
	if Global.Is_Game_Active == true:
		SignalManager.show_pause_menu.emit()
		return
	else:
		SignalManager.show_main_menu.emit()
		return

@onready var ObjectLoaderContainer = self.get_parent()
var OverlayMaterial = preload(Path.OverlayEffectPath)

func manage_overlay():
	if Global.Settings_Data_Instance.Is_Overlay_Effect_Enabled != true:
		if ObjectLoaderContainer.get_material() != null:
			ObjectLoaderContainer.material = null
		return
	if ObjectLoaderContainer.get_material() == null:
		ObjectLoaderContainer.material = OverlayMaterial
	return

func _process(_delta):
	manage_overlay()
	Global.MousePosition2D = get_viewport().get_mouse_position()

	if User_Interface_Instance == null:
		User_Interface_Instance.add_child(Movement_Interface_Instance)
		return
	else:
		pass

func manage_game_world_signals():
		if SignalManager.load_intro_animation.is_connected(Callable(add_object)):
			SignalManager.load_intro_animation.disconnect(Callable(add_object))
		SignalManager.load_intro_animation.connect(Callable(add_object).bind(Path.IntroAnimationPath, Intro_Animation_Instance, User_Interface_Instance))

		if SignalManager.load_pause_menu.is_connected(Callable(add_object)):
			SignalManager.load_pause_menu.disconnect(Callable(add_object))
		SignalManager.load_pause_menu.connect(Callable(add_object).bind(Path.PauseMenuPath, Pause_Menu_Instance, User_Interface_Instance))

		if SignalManager.load_options_menu.is_connected(Callable(add_object)):
			SignalManager.load_options_menu.disconnect(Callable(add_object))
		SignalManager.load_options_menu.connect(Callable(add_object).bind(Path.OptionsMenuPath, Options_Menu_Instance, User_Interface_Instance))

		if SignalManager.load_movement_interface.is_connected(Callable(add_object)):
			SignalManager.load_movement_interface.disconnect(Callable(add_object))
		SignalManager.load_movement_interface.connect(Callable(add_object).bind(Path.MovementInterfacePath, Movement_Interface_Instance, User_Interface_Instance))

		if SignalManager.load_game_over_screen.is_connected(Callable(add_object)):
			SignalManager.load_game_over_screen.disconnect(Callable(add_object))

		if SignalManager.load_game_over_screen.is_connected(Callable(add_object)):
			SignalManager.load_game_over_screen.disconnect(Callable(add_object))
		SignalManager.load_game_over_screen.connect(Callable(add_object).bind(Path.GameOverScreenPath, Game_Over_Screen_Instance, User_Interface_Instance))

		if SignalManager.load_task_list.is_connected(Callable(add_object)):
			SignalManager.load_task_list.disconnect(Callable(add_object))
		SignalManager.load_task_list.connect(Callable(add_object).bind(Path.TaskListPath, Task_List_Instance, User_Interface_Instance))

		if SignalManager.load_dialogue_box.is_connected(Callable(add_object)):
			SignalManager.load_dialogue_box.disconnect(Callable(add_object))
		SignalManager.load_dialogue_box.connect(Callable(add_object).bind(Path.DialogueBoxPath, Dialogue_Box_Instance, User_Interface_Instance))

		if SignalManager.load_player.is_connected(Callable(add_object)):
			SignalManager.load_player.disconnect(Callable(add_object))
		SignalManager.load_player.connect(Callable(add_object).bind(Path.PlayerPath, Local_Player_Instance, Game_World_Instance))

		if SignalManager.load_monster.is_connected(Callable(add_object)):
			SignalManager.load_monster.disconnect(Callable(add_object))
		SignalManager.load_monster.connect(Callable(add_object).bind(Path.MonsterPath, Local_Monster_Instance, Game_World_Instance))

func on_scene_loaded(resource: PackedScene):
	var InstancedResource = resource.instantiate()
	if resource == preload(Path.GameWorldPath):

		if Global.Loaded_Game_World != null:
			Global.Loaded_Game_World.queue_free()
		if Game_World_Instance != null:
			Game_World_Instance.queue_free()

		Game_World_Instance = InstancedResource
		Global.Loaded_Game_World = Game_World_Instance
		manage_game_world_signals()
		self.add_child(Game_World_Instance)
		SignalManager.load_game_world.emit()
		return

	if resource == preload(Path.MainMenuPath):
		Main_Menu_Instance = InstancedResource
		User_Interface_Instance.add_child(InstancedResource)
		Global.Loaded_Main_Menu = Main_Menu_Instance
		return
	pass

func on_activate_popup(text: String, wait_time: float):
	if Popup_Instance != null:
		Popup_Instance.queue_free()

	Popup_Instance = load(str(Path.PopupScenePath)).instantiate()
	User_Interface_Instance.add_child(Popup_Instance)
	Popup_Instance.play_animation(text, wait_time)
	pass

func manage_signals():
	SignalManager.scene_loaded.connect(Callable(on_scene_loaded))
	SignalManager.load_audio_manager.connect(Callable(add_object).bind(Path.AudioManagerPath, Audio_Manager_Instance, self))
	SignalManager.main_menu_loaded.connect(Callable(on_main_menu_loaded))
	SignalManager.game_world_loaded.connect(Callable(on_game_world_loaded))
	SignalManager.exit_options_menu.connect(Callable(on_exit_options_menu))
	SignalManager.room_loaded.connect(Callable(on_room_loaded))
	SignalManager.activate_popup.connect(Callable(on_activate_popup))

func _ready():
	Global.Object_Loader = self
	manage_signals()

	Global.verify_settings_file_directory()
	SignalManager.load_audio_manager.emit()
	load_user_interface()
	LoadManager.load_scene(Path.MainMenuPath)
