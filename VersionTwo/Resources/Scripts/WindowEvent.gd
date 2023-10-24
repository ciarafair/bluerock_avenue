extends LocationBlock

@onready var AnimationPlayerInstance: AnimationPlayer = $AnimationPlayer
@export var Is_Window_Open: bool

var Is_Monster_In: int = 0

func on_animation_finished():
	print_debug("Monster inside")

func on_open_window():
	Is_Monster_In = Is_Monster_In + 1
	Global.Is_Window_Being_Opened = true
	AnimationPlayerInstance.speed_scale = 1
	AnimationPlayerInstance.play("open_window")

func on_close_window():
	Is_Monster_In = Is_Monster_In - 1
	Global.Is_Window_Open = false
	Global.Is_Window_Being_Opened = false
	AnimationPlayerInstance.speed_scale = 5
	AnimationPlayerInstance.play_backwards("open_window")

func start_event():
	print_debug("Starting event " + self.name)
	Global.Current_Event = "window"
	if SignalManager.open_window.is_connected(on_open_window):
		pass
	else:
		SignalManager.open_window.connect(on_open_window)

	if SignalManager.close_window.is_connected(on_close_window):
		pass
	else:
		SignalManager.close_window.connect(on_close_window)

func _ready():
	AnimationPlayerInstance.speed_scale = 1

	search_for_parent_block(self)
	search_for_camera_position(self)
	search_for_collider(self)

	if BlockCollider != null:
		BlockCollider.set_disabled(true)

	if BlockCollider == null:
		print_debug(str(self.name) + " does not have a collider.")

func _process(_delta):
	set_rotation_ability()

	if Global.Current_Active_Block == self && Global.Current_Event != "window":
		search_for_props(self, true)
		start_event()


	if SignalManager.activate_block.is_connected(on_activate_block) and SignalManager.deactivate_block.is_connected(on_deactivate_block):
		if Global.Current_Active_Block != self:
			SignalManager.activate_block.disconnect(on_activate_block)
			SignalManager.deactivate_block.disconnect(on_deactivate_block)
	else:
		if Global.Current_Active_Block == self:
			SignalManager.activate_block.connect(on_activate_block)
			SignalManager.deactivate_block.connect(on_deactivate_block)

	if Global.Hovering_Block == self and !SignalManager.activate_block.is_connected(on_activate_block):
		SignalManager.activate_block.connect(on_activate_block)

func _on_animation_player_animation_finished(_window_open):
#	print_debug(window_open + " animation completed.")
	if Is_Monster_In > 0:
		print_debug("Monster got in: " + str(Is_Monster_In))
	pass

func _on_animation_player_animation_started(_window_open):
#	print_debug(window_open + " animation started.")
	pass
