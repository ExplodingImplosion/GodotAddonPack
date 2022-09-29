extends Area
class_name BoundingBox

export(float,0.1,999) var min_size: float

var offset: Vector3
#var size: Vector3

onready var collisionshape: CollisionShape = $CollisionShape
onready var parent: Spatial = get_parent()

func _init(size: Vector3) -> void:
	scale = size
#	size = _size
#	new_collision_shape()
#	apply_size()

func new_collision_shape() -> void:
	collisionshape.set_shape(BoxShape.new())

#func apply_size() -> void:
#	(collisionshape.shape as BoxShape).set_extents(size)

# why offset just the collision shape when you can just use transform.origin?
# like mayyyyyyyyybe only doing it for the collisionshape saves a couple
# cpu cycles, but like idek if thats the case LMFAO
#func apply_offset() -> void:
#	collisionshape.transform.origin = offset

func _physics_process(delta: float) -> void:
	if qNetwork.is_server():
		var delay: int = Inputs.get_player_cached_inputs(parent.owner_id).size()
		var size: Vector3 = scale
		var posdiff: Vector3
		for input in delay:
			pass
			# go back for a frame
			# if the parent existed on that frame
#			var entity: SnapEntityBase = snapshot.get_entity(nhash,parent.uid)
#			if entity:
#				posdiff += entity.position - parent.global_transform.origin
		posdiff += parent.size
		# probably redundant because there's no shot parent.size AND posdiff are 0
		enforce_min_size(posdiff.x)
		enforce_min_size(posdiff.y)
		enforce_min_size(posdiff.z)
		scale = posdiff
#		global_transform.origin = 
		# leftover code in case wanna do shit with collision shapes
#		parent.collisionshape

func enforce_min_size(value: float) -> float:
	return min_size if is_zero_approx(value) else value
