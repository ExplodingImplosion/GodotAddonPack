extends Position3D

var orientation: Vector3
var position: Vector3

func update() -> void:
	orientation = global_rotation
	position = global_transform.origin
