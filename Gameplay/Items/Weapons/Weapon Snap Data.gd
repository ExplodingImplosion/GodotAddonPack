extends SnapEntityBase
class_name WeaponSnapData

var owner_id: int = 1
var equip_time_left: float
var sway: Vector3
var fire_time_left: float
var cycled: bool
var can_fire: bool
var trying_to_fire: bool
var released_fire: bool
var fired: bool

func _init(uid: int, chash: int).(uid,chash) -> void:
	pass

func apply_state(node: Node) -> void:
	apply_vars(node)

func apply_vars(to: Weapon) -> void:
	to.has_correction = true
	to.correction_data = make_correction_data()

func make_correction_data() -> Dictionary:
	return {
	owner_id = owner_id,
	equip_time_left = equip_time_left,
	sway = sway,
	fire_time_left = fire_time_left,
	cycled = cycled,
	can_fire = can_fire,
	trying_to_fire = trying_to_fire,
	released_fire = released_fire,
	fired = fired,
	}

func get_vars(from: Weapon) -> void:
	owner_id = from.owner_id
	equip_time_left = from.equip_time_left
	sway = from.sway
	fire_time_left = from.fire_time_left
	cycled = from.cycled
	can_fire = from.can_fire
	trying_to_fire = from.trying_to_fire
	released_fire = from.released_fire
	fired = from.fired
