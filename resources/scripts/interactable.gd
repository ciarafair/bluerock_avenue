extends StaticBody3D
class_name Interactable

enum type {
	UNSELECTED = 0,
	DIALOGUE = 1,
	OBTAINABLE = 2
}

@onready var InteractableCollider = find_collider()

@export var DialoguePath: String
@export var InteractableType: type

func find_collider() -> CollisionShape3D:
	for child in self.get_children():
		if child is CollisionShape3D:
			return child
	return null

func enable_collider():
	if self.InteractableCollider != null && self.InteractableCollider.is_disabled() == true:
		#print_rich("Enabling the item %s" %[self.name])
		#Global.stack_info(get_stack())
		self.InteractableCollider.set_disabled(false)

func disable_collider():
	if self.InteractableCollider != null && self.InteractableCollider.is_disabled() == false:
		#print_rich("Disabling the item %s" %[self.name])
		#Global.stack_info(get_stack())
		self.InteractableCollider.set_disabled(true)

func manage_dialogue():
		if self.DialoguePath != null:
			var json = load(self.DialoguePath)
			var stringified_json = Global.stringify_json(json)
			print_rich("Activating %s with the dialogue %s." %[self.name, stringified_json])
			Global.stack_info(get_stack())
			SignalManager.click_dialogue.emit(stringified_json)
			return
		else:
			print_rich("Dialogue path not entered.")
			Global.stack_info(get_stack())
			return

func manage_type():
	match self.InteractableType:
		type.UNSELECTED:
			print_rich("Type not selected on interactable %s." %[self.name])
			Global.stack_info(get_stack())
			return

		type.DIALOGUE:
			manage_dialogue()
			return

		type.OBTAINABLE:
			SignalManager.activate_popup.emit("Picked up %s." %[self.name], 0.5)
			Global.add_to_inventory(self)
			manage_visibility()
			return

func manage_visibility():
	if Global.Game_Data_Instance.PlayerInventory.has(self):
		self.disable_collider()
		self.set_visible(false)

func activate():
	manage_type()
	return

func _ready():
	self.disable_collider()
	await SignalManager.player_data_loaded
	manage_visibility()

