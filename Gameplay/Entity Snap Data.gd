extends SnapEntityBase
class_name EntitySnapData

var owner_id: int = 1

func _init(uid: int, chash: int).(uid,chash) -> void:
	pass

func apply_state(node: Node) -> void:
	apply_vars(node)

func apply_vars(to: Entity) -> void:
	to.has_correction = true
	to.correction_data =  make_correction_data()

func make_correction_data() -> Dictionary:
	return {
	owner_id = owner_id,
	}

func get_vars(from: Entity) -> void:
	owner_id = from.owner_id
