extends StaticBody3D
class_name Interactable

enum type {
	UNSELECTED = 0,
	DIALOGUE = 1,
	OBTAINABLE = 2
}

@onready var ItemCollider = find_collider()

@export var DialoguePath: String
@export var InteractableType: type

func find_collider() -> CollisionShape3D:
	for child in self.get_children():
		if child is CollisionShape3D:
			return child
	return null

func enable_collider():
	if self.ItemCollider != null:
		#print_rich("Enabling the item %s" %[self.name])
		#Global.stack_info(get_stack())
		self.ItemCollider.set_disabled(false)

func disable_collider():
	if self.ItemCollider != null:
		#print_rich("Disabling the item %s" %[self.name])
		#Global.stack_info(get_stack())
		self.ItemCollider.set_disabled(true)

func manage_dialogue():
		if DialoguePath != null:
			var json = load(DialoguePath)
			var stringified_json = Global.stringify_json(json)
			print_rich("Activating %s with the dialogue %s." %[self.name, stringified_json])
			Global.stack_info(get_stack())
			SignalManager.click_dialogue.emit(self, stringified_json)
			return
		else:
			print_rich("Dialogue path not entered.")
			Global.stack_info(get_stack())
			return

func manage_visibility():
	for item in Global.Game_Data_Instance.PlayerInventory:
		if item.name == self.name:
			self.set_visible(false)
			self.disable_collider()
			return

	self.set_visible(true)
	self.enable_collider()
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
			return

func activate():
	manage_type()

func _ready():
	self.disable_collider()

func _process(_delta):
	if self.InteractableType == type.OBTAINABLE:
		manage_visibility()
