extends Block
class_name LocationBlock

func _ready():
	block_ready()

	self.search_for_locations(self)
	self.search_for_interactables(self)
	if self.Locations != []:
		print_rich("%s has %s locations. \n %s" %[self.name, self.Locations.size(), self.Locations])
		Global.stack_info(get_stack())
	if self.Interactables != []:
		print_rich("%s has %s interactables. \n %s" %[self.name, self.Interactables.size(), self.Interactables])
		Global.stack_info(get_stack())
