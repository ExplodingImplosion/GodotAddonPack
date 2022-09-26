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
