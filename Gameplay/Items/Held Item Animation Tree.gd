extends AnimationTree
class_name HeldAnimTree

const params: String = "parameters/"
const timescale: String = params+"Time Scale/scale"
const addmovement: String = params+"Add Movement/add_amount"
const jumporwalk: String = params+"Jump or Walk/blend_amount"
const jumporidle: String = params+"Jump or Idle/active"
const walkseek: String = params+"Walk Seek/seek_position"
onready var walkanim: Animation = (get_node(anim_player) as AnimationPlayer).get_animation("Walk")

onready var root: AnimationNodeBlendTree = tree_root

func set_timescale(scale: float) -> void:
	set(timescale,scale)

func jump() -> void:
	set(jumporidle,true)
	set_walk_scale(0.0)

func stop_jump() -> void:
	set(jumporidle,false)

func set_walk_scale(scale: float) -> void:
	var prev_walk: float = get(jumporwalk)
	if prev_walk == 0.0 and scale != 0.0:
		seek_walk(0.0)
	set(jumporwalk,scale)

func enable_move_anims(enable: bool) -> void:
	set(addmovement,float(enable))

func seek_walk(time: float) -> void:
	set(walkseek,time)
