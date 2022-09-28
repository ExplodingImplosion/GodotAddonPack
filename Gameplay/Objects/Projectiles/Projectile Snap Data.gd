extends SnapEntityBase
class_name ProjectileSnapData

var owner_id: int = 1
var position: Vector3
var velocity: Vector3
var orientation: Vector3

func _init(uid: int, chash: int).(uid,chash) -> void:
	pass

func apply_state(node: Node) -> void:
	apply_vars(node)

func apply_vars(to: Projectile) -> void:
	to.has_correction = true
	to.correction_data = {
	owner_id = owner_id,
	position = position,
	velocity = velocity,
	orientation = orientation,
	}

func get_vars(from: Projectile) -> void:
	owner_id = from.owner_id
	position = from.position
	velocity = from.velocity
	orientation = from.orientation
