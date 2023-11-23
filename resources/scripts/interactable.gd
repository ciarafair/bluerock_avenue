extends StaticBody3D
class_name Interactable

@onready var ItemCollider = find_collider()

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

func activate():
	print_debug("Activating %s" %[self.name])

func _ready():
	self.disable_collider()
