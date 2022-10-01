extends Node
class_name BoundingBox

export(float,0.1,999) var min_size: float

var offset: Vector3
#var size: Vector3

onready var area: Area = $Area
onready var collisionshape: CollisionShape = $Area/CollisionShape
onready var parent: Spatial = get_parent()

#func _init(size: Vector3) -> void:
#	scale = size
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

#func get_owner_player() -> NetPlayerNode:
#	return Network.player_data.remote_player.get(parent.owner_id) # Network.player_data.local_player if parent.owner_id == 1 else 
# warning-ignore:unused_argument

func _physics_process(delta: float) -> void:
	var history: Array= Network.snapshot_data._history
	if qNetwork.is_server() and !history.empty():
		var delay: int = qNetwork.max_player_delay
		var maxpos: Vector3 = parent.global_transform.origin
		var minpos: Vector3 = maxpos
		var posdiff: Vector3
		for i in delay:
			# prevents frame delays greater than max history size from looping around in array
			# and accessing redundant data
			if i+1 > history.size():
				break
			var idx: int = -(i+1)
			var snapshot: NetSnapshot = history[idx]
			var entity: SnapEntityBase = snapshot.get_entity(parent.namehash,parent.owner_id)
			if entity:
				maxpos = set_if_greater(maxpos,entity.position)
				minpos = set_if_lesser(minpos,entity.position)
			else:
				# there is like zero shot that the entity was simply "not present" on one frame
				# back in time and then present the next frame back in time, so this bails
				# from the loop if the entity isn't present on a given frame
				break
		posdiff = maxpos-minpos
		if parent.size.length() > 0:
			# probably redundant because there's no shot parent.size AND posdiff are 0
			posdiff.x = enforce_min_size(posdiff.x)
			posdiff.y = enforce_min_size(posdiff.y)
			posdiff.z = enforce_min_size(posdiff.z)
		area.scale = posdiff + parent.size
		area.global_transform.origin = maxpos - posdiff/2
		area.global_transform.origin.y += parent.size.y/2
		# leftover code in case wanna do shit with collision shapes
#		parent.collisionshape

func enforce_min_size(value: float) -> float:
	return min_size if is_zero_approx(value) else value

static func set_if_greater(v1: Vector3, v2: Vector3) -> Vector3:
	v1.x = sig(v1.x,v2.x)
	v1.y = sig(v1.y,v2.y)
	v1.z = sig(v1.z,v2.z)
	return v1

static func sig(v1: float, v2: float) -> float:
	return v2 if v2 > v1 else v1

static func sil(v1: float, v2: float) -> float:
	return v2 if v2 < v1 else v1

static func set_if_lesser(v1: Vector3, v2: Vector3) -> Vector3:
	v1.x = sil(v1.x,v2.x)
	v1.y = sil(v1.y,v2.y)
	v1.z = sil(v1.z,v2.z)
	return v1
