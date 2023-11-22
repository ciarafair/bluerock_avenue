extends Marker3D
class_name CameraPosition

func manage_rotation():
	if self.rotation_degrees.y > 360:
		self.rotation_degrees.y -= 360
		return

	if self.rotation_degrees.y == 360:
		self.rotation_degrees.y = 0

	if self.rotation_degrees.y < -360:
		self.rotation_degrees.y += 360
		return

	if self.rotation_degrees.y == -360:
		self.rotation_degrees.y = 0

func _process(_delta):
	manage_rotation()
