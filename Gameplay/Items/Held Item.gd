extends Entity
class_name Held

export(float,0,10) var equip_time: float
export(float,0,1) var weight: float
export(float,-10,10) var horizontal_sway_factor: float
export(float,-1000,1000) var max_horizontal_sway: float
export(float,-10,10) var vertical_sway_factor: float
export(float,-1000,1000) var max_vertical_sway: float
export(float,-10,10) var tilt_factor: float
export(float,-1000,1000) var max_tilt: float
export(float,-100,100) var movement_tilt_factor: float
export(float,0,100) var sway_return_factor: float
export var can_be_dropped: bool
export var dropped_scene: PackedScene
export(int,0,100) var dropped_resource_index: int

var equip_time_left: float
var sway: Vector3
onready var player: KinematicBody = get_parent()
onready var rotational_parent: Position3D = $"Rotational Parent"
onready var mesh: MeshInstance = $"Rotational Parent/Item Mesh"

func _init() -> void:
	._init()
	

func input1() -> void:
	pass

func input2() -> void:
	pass

func input3() -> void:
	pass

func on_equip_finished() -> void:
	pass

func equip() -> void:
	pass
#	show()

func unequip() -> void:
	if is_equipping():
		pass

func is_equipping() -> bool:
	return false

func drop() -> void:
	pass

func tick_sway(delta: float) -> void:
	update_sway()
	tick_sway_return(delta)

func update_sway() -> void:
	rotational_parent.set_rotation_degrees(sway)

func tick_sway_return(delta: float) -> void:
	sway = sway.linear_interpolate(Vector3.ZERO,delta*sway_return_factor)

func reset_sway() -> void:
	sway = Vector3(0,0,sway.z)

func reset_tilt() -> void:
	sway.z = 0

func reset_sway_and_tilt() -> void:
	sway = Vector3.ZERO

func set_sway(new_sway: Vector2) -> void:
	sway.x = new_sway.y
	sway.y = new_sway.x

func modify_sway(direction: Vector2) -> void:
	sway.x = clamp(sway.x + (direction.y * vertical_sway_factor),max_vertical_sway,-max_vertical_sway)
	sway.y = clamp(sway.y + (direction.x * horizontal_sway_factor),max_horizontal_sway,-max_horizontal_sway)
	sway.z = clamp(sway.z + (direction.x * tilt_factor),max_tilt,-max_tilt)

func modify_tilt_from_movement(value: float) -> void:
	sway.z += value * movement_tilt_factor

func simulate(delta: float) -> void:
	tick_sway(delta)
