extends Area
class_name BoundingBox

var offset: Vector3
var size: Vector3

onready var collisionshape: CollisionShape = $CollisionShape

func _init(_size: Vector3) -> void:
	size = _size
	new_collision_shape()
	apply_size()

func new_collision_shape() -> void:
	collisionshape.set_shape(BoxShape.new())

func apply_size() -> void:
	(collisionshape.shape as BoxShape).set_extents(size)

func apply_offset() -> void:
	collisionshape.transform.origin = offset
