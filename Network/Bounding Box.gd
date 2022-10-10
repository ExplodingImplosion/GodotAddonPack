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
	if !qNetwork.is_server():
		return
	update_size_from_net_history_and_max_player_delay()

func update_size_from_net_history_and_max_player_delay() -> void:
	var history: Array = qNetwork.get_recent_snapshot_history()
	if !history.empty():
		var delay: int = qNetwork.max_player_frame_delay
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
			var entity: SnapEntityBase = Entity.get_entity_from_snapshot(snapshot,parent)
			if entity:
				maxpos = set_if_greater(maxpos,entity.position)
				minpos = set_if_lesser(minpos,entity.position)
			else:
				# there is like zero shot that the entity was simply "not present" on one frame
				# back in time and then present the next frame back in time, so this bails
				# from the loop if the entity isn't present on a given frame
				break
		posdiff = maxpos-minpos
		if is_zero_approx(parent.size.length()):
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


# maybe make this a CollisionObject instead
func on_body_entered(body: PhysicsBody):
	# maybe just connect this func on startup but only if is server,
	# or disconnect this func on startup only if it isnt server
	if !qNetwork.is_server():
		return
	# this should be the only eventuality
	assert(Collision.network_collision(body))
	# dont need to rewind for stuff if its a server owned body
	if body.owner_id == 1:
		return
	var history: Array = qNetwork.get_recent_snapshot_history()
	if !history.empty():
		var body_owner_delay: int = qNetwork.get_cached_player_frame_delay(body.owner_id)
		var parent_entity: SnapEntityBase = parent.generate_snap_entity()
		var body_entity: SnapEntityBase = body.generate_snap_entity()
		var original_parent_entity: SnapEntityBase = parent_entity
		var original_body_entity: SnapEntityBase = body_entity
		
		
		# body needs to resimulate so we're going to rewind back to the delay + 1 for body
		# but NOT for the parent
		
		# ALSO THIS SHOULD BE REWRITTEN TO REWIND FROM FURTHEST POINT BACK FORWARDS INSTEAD
		# OF REWINDING BACKWARDS FROM MOST RECENT FRAME
		for i in body_owner_delay+1:
			# prevents frame delays greater than max history size from looping around in array
			# and accessing redundant data
			if i+1 > history.size():
				break
			var idx: int = -(i+1)
			var snapshot: NetSnapshot = history[idx]
			var this_parent_entity: SnapEntityBase = Entity.get_entity_from_snapshot(snapshot,parent)
			var this_body_entity: SnapEntityBase = Entity.get_entity_from_snapshot(snapshot,body)
			# makes sure that when rewinding back the parent isnt rewound to the wrong one, because
			# of resimulating weirdness
			if this_parent_entity and i != body_owner_delay:
				parent_entity = this_parent_entity
			if this_body_entity:
				body_entity = this_body_entity
			if !this_parent_entity and !this_body_entity:
				# there is like zero shot that the entities were simply "not present" on one frame
				# back in time and then present the next frame back in time, so this bails
				# from the loop if both entities aren't present on a given frame
				break
		var parent_entities_same: bool = parent_entity != original_parent_entity
		var body_entities_same: bool = body_entity != original_body_entity
		if !parent_entities_same:
			apply_vars_to_node_from_snapentity(parent,parent_entity)
#		elif body_entities_same:
#			var bodyparent: Node = body.get_parent()
#			bodyparent.remove_child(body)
#			bodyparent.add_child(body)
		# this shit is prolly gonna break
		if !body_entities_same:
			apply_vars_to_node_from_snapentity(body,body_entity)
			body.simulate(get_physics_process_delta_time())
		
		if !parent_entities_same:
			apply_vars_to_node_from_snapentity(parent,original_parent_entity)
		if !body_entities_same:
			apply_vars_to_node_from_snapentity(body,original_body_entity)
#	else:
#		printerr("body %s doesnt have network collision set up and neither does bounding box %s, layers/masks are %s/%s and %s/%s"%[body,self,body.collision_layer,body.collision_mask,area.collision_layer,area.collision_mask])
#		Quack.quit()

static func apply_vars_to_node_from_snapentity(node: Spatial, entity: SnapEntityBase) -> void:
	entity.apply_state(node)
	node.apply_corrections()
