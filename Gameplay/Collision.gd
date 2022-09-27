extends Object
class_name Collision

enum {WORLD=1,DAMAGE=2,KNOCKBACK=4,NETWORK=8}
static func is_damageable(node: CollisionObject) -> bool:
	return node.collision_mask && DAMAGE

static func accepts_damage(node: CollisionObject) -> bool:
	return is_damageable(node)

static func collides_with_world(node: CollisionObject) -> bool:
	return node.collision_layer && WORLD

static func accepts_knockback(node: CollisionObject) -> bool:
	return node.collision_mask && KNOCKBACK

static func can_be_knocked_back(node: CollisionObject) -> bool:
	return accepts_knockback(node)

static func network_collision(node: CollisionObject) -> bool:
	return node.collision_mask && NETWORK
