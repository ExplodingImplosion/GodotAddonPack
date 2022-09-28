extends SnapEntityBase
class_name HeldSnapData

var owner_id: int = 1
var equip_time_left: float
var sway: Vector3

func _init(uid: int, chash: int).(uid,chash) -> void:
	pass

func apply_state(node: Node) -> void:
	apply_vars(node)

func apply_vars(to: Held) -> void:
	to.has_correction = true
	to.correction_data = {
	owner_id = owner_id,
	equip_time_left = equip_time_left,
	sway = sway,
	}

func get_vars(from: Held) -> void:
	owner_id = from.owner_id
	equip_time_left = from.equip_time_left
	sway = from.sway
