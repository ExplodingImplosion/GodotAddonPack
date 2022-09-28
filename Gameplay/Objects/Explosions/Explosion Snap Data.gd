extends SnapEntityBase
class_name ExplosionSnapData

var owner_id: int = 1
var frame_created: int
var deletion_frame: int

func _init(uid: int, chash: int).(uid,chash) -> void:
	pass

func apply_state(node: Node) -> void:
	apply_vars(node)

func apply_vars(to: Explosion) -> void:
	to.has_correction = true
	to.correction_data = {
	owner_id = owner_id,
	frame_created = frame_created,
	deletion_frame = deletion_frame,
	}

func get_vars(from: Explosion) -> void:
	owner_id = from.owner_id
	frame_created = from.frame_created
	deletion_frame = from.deletion_frame
