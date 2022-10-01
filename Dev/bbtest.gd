extends Spatial

export(float,0.1,999) var min_size: float
onready var parent: Position3D = $Position3D
onready var pos2: Position3D = $Position3D2
onready var area: Area = $Area

func _ready() -> void:
	var maxpos: Vector3 = parent.global_transform.origin
	var minpos: Vector3 = maxpos
	var posdiff: Vector3
	maxpos = BoundingBox.set_if_greater(maxpos,pos2.global_transform.origin)
	minpos = BoundingBox.set_if_lesser(minpos,pos2.global_transform.origin)
	posdiff = maxpos-minpos
	area.scale = posdiff
	area.global_transform.origin = maxpos - posdiff/2
	prints(area.global_transform.origin)

func enforce_min_size(value: float) -> float:
	return min_size if is_zero_approx(value) else value
