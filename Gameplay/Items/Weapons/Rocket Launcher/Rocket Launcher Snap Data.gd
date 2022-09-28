extends SnapEntityBase
class_name RocketLauncherSnapData

var owner_id: int = 1
var equip_time_left: float
var sway: Vector3
var fire_time_left: float
var cycled: bool
var can_fire: bool
var trying_to_fire: bool
var released_fire: bool
var fired: bool
var current_ammo: int
var reload_time_left: float
var chamber_time_left: float

func _init(uid: int, chash: int).(uid,chash) -> void:
	pass

func apply_state(node: Node) -> void:
	apply_vars(node)

func apply_vars(to: SingleLoader) -> void:
	to.has_correction = true
	to.correction_data = {
	owner_id = owner_id,
	equip_time_left = equip_time_left,
	sway = sway,
	fire_time_left = fire_time_left,
	cycled = cycled,
	can_fire = can_fire,
	trying_to_fire = trying_to_fire,
	released_fire = released_fire,
	fired = fired,
	current_ammo = current_ammo,
	reload_time_left = reload_time_left,
	chamber_time_left = chamber_time_left,
	}

func get_vars(from: SingleLoader) -> void:
	owner_id = from.owner_id
	equip_time_left = from.equip_time_left
	sway = from.sway
	fire_time_left = from.fire_time_left
	cycled = from.cycled
	can_fire = from.can_fire
	trying_to_fire = from.trying_to_fire
	released_fire = from.released_fire
	fired = from.fired
	current_ammo = from.current_ammo
	reload_time_left = from.reload_time_left
	chamber_time_left = from.chamber_time_left
