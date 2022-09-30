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

func get_owner_player() -> NetPlayerNode:
	return Network.player_data.remote_player.get(parent.owner_id) # Network.player_data.local_player if parent.owner_id == 1 else 

func get_ping(player: NetPlayerNode) -> float:
	return player._ping.last_ping if player._ping else 0.0

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if qNetwork.is_server():
		#												lmao ping is measured in ms
		var player: NetPlayerNode = get_owner_player()
		# the frame after player is cleared from remote player dict the bounding
		# box still exists, this prevents script errors for frame after deletion
		if !player:
			return
		var delay: int = get_ping(player) / (delta * 1000) + 1
		var maxpos: Vector3 = area.global_transform.origin
		var minpos: Vector3 = maxpos
		var posdiff: Vector3
		# maybe delay -1?
		for input in delay:
			var snapshot: NetSnapshot = Network.snapshot_data._history[-(input + 1)]
			var entity: SnapEntityBase = snapshot.get_entity(parent.namehash,parent.owner_id)
			if entity:
				maxpos = set_if_greater(maxpos,entity.position)
				minpos = set_if_lesser(minpos,entity.position)
			# maybe bail from loop if entity not present?
		posdiff = maxpos.abs() + minpos.abs()
		if parent.size.length() > 0:
			# probably redundant because there's no shot parent.size AND posdiff are 0
			posdiff.x = enforce_min_size(posdiff.x)
			posdiff.y = enforce_min_size(posdiff.y)
			posdiff.z = enforce_min_size(posdiff.z)
		area.scale = posdiff + parent.size
		area.global_transform.origin = maxpos - posdiff/2
		# leftover code in case wanna do shit with collision shapes
#		parent.collisionshape

func enforce_min_size(value: float) -> float:
	return min_size if is_zero_approx(value) else value

func set_if_greater(v1: Vector3, v2: Vector3) -> Vector3:
	v1.x = v2.x if v2.x > v1.x else v2.x
	v1.y = v2.y if v2.y > v1.y else v2.y
	v1.z = v2.z if v2.z > v1.z else v2.z
	return v1

func set_if_lesser(v1: Vector3, v2: Vector3) -> Vector3:
	v1.x = v2.x if v2.x < v1.x else v2.x
	v1.y = v2.y if v2.y < v1.y else v2.y
	v1.z = v2.z if v2.z < v1.z else v2.z
	return v1
