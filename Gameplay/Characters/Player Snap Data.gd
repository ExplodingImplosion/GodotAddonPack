extends SnapEntityBase
class_name PlayerSnapData

var owner_id: int = 1
var position: Vector3
var velocity: Vector3
var input_dir: Vector2
var inputs: int
var aim_angle: Vector2
#var weapons: Array
#var grenades: Array
var health: float = 100
var max_health: float = 100
var dead: bool = false
var crouch_amount: float
var team: int
var jumped: int
#const uid = 0

func _init(uid: int, chash: int).(uid,chash) -> void:
	pass
#	set_meta("class_hash",chash)
#	set_meta("owner_id",EntityInfo.CTYPE_UINT)

func apply_state(node: Node) -> void:
	apply_vars(node)

func apply_vars(to: PlayerCharacter) -> void:
	to.has_correction = true
	to.correction_data = make_correction_data()

func make_correction_data() -> Dictionary:
	return {
	owner_id = owner_id,
	position = position,
	velocity = velocity,
	input_dir = input_dir,
	inputs = inputs,
	aim_angle = aim_angle,
	#weapons = weapons,
	#grenades = grenades,
	health = health,
	max_health = max_health,
	dead = dead,
	crouch_amount = crouch_amount,
	team = team,
	jumped = jumped,
	}

func get_vars(from: PlayerCharacter) -> void:
	owner_id = from.owner_id
	position = from.global_transform.origin
	velocity = from.velocity
	input_dir = from.input_dir
	inputs = from.inputs
	aim_angle = from.aim_angle
	#weapons = from.weapons
	#grenades = from.grenades
	health = from.health
	max_health = from.max_health
	dead = from.dead
	crouch_amount = from.crouch_amount
	team = from.team
	jumped = from.jumped
