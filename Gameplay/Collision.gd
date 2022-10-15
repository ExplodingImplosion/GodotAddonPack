extends Object
class_name Collision

enum {WORLD=1,DAMAGE=2,KNOCKBACK=4,NETWORK=8}
static func is_damageable(node: CollisionObject) -> bool:
	return node.collision_layer && DAMAGE

static func accepts_damage(node: CollisionObject) -> bool:
	return is_damageable(node)

static func can_be_damaged(node: CollisionObject) -> bool:
	return is_damageable(node)

static func can_damage_happen(from: CollisionObject, to: CollisionObject) -> bool:
	return collision_damages(from) and is_damageable(to)

static func collides_with_world(node: CollisionObject) -> bool:
	return node.collision_layer && WORLD # maybe change this to collision_layer and collision_mask?
										 # maybe even just collision_mask? Because the mask is
										 # what determines 'scanning' for collisions and layer is what
										 # what determines 'recieving' collisions

static func accepts_knockback(node: CollisionObject) -> bool:
	return node.collision_layer && KNOCKBACK

static func can_be_knocked_back(node: CollisionObject) -> bool:
	return accepts_knockback(node)

static func can_knockback_happen(from: CollisionObject, to: CollisionObject) -> bool:
	return can_node_knockback(from) and accepts_knockback(to)

static func network_collision(node: CollisionObject) -> bool:
	return node.collision_mask && NETWORK

static func can_node_damage(node: CollisionObject) -> bool:
	return node.collision_mask && DAMAGE

static func collision_damages(node: CollisionObject) -> bool:
	return can_node_damage(node)

static func can_node_knockback(node: CollisionObject) -> bool:
	return node.collision_mask && KNOCKBACK

static func collision_knockbacks(node: CollisionObject) -> bool:
	return can_node_knockback(node)

static func get_collision_dimensions(collider: CollisionShape) -> Vector3:
	var shape: Shape = collider.shape
	var rotation: Vector3 = collider.global_rotation
#	if rotation != Vector3.ZERO:
#		assert(false)
	var scale: Vector3 = collider.scale
	assert(shape is BoxShape or shape is CapsuleShape or shape is SphereShape or shape is CylinderShape)
	if shape is BoxShape:
		return shape.extents*2*scale
	elif shape is CapsuleShape:
		# capsules are weird in godot 3
		if shape.height >= 1:
			return Vector3(shape.radius,shape.radius,shape.height)*2*scale
		else:
			return Vector3(shape.radius*2,shape.radius*2,1)*scale
	elif shape is SphereShape:
		return shape.radius*2*scale
	elif shape is CylinderShape:
		return Vector3(shape.radius*2,shape.height,shape.radius*2)*scale
	else:
		return Vector3.ZERO
