extends Area
class_name Explosion

# this is fucking insane but it needs to be done for bounding boxes to work because
# scritps cant pull their class name
var namehash: int = hash("ExplosionSnapData")

var resource_id: int
var has_correction: bool
var owner_id: int = 1
var correction_data: Dictionary
export var snap_entity_script: Script

enum {NONE,LINEAR,SQUARED,STEPPED,CURVE}
export(float,0,500) var damage: float
export(float,-100,100) var knockback: float
export(float,0,9223372036854775807) var size: float
export var infinite_active_lifetime: bool
export(float,0,9223372036854775807) var active_lifetime: float
export var infinite_lifetime: bool
export(float,0,9223372036854775807) var lifetime: float
export(int,"None","Linear","Squared","Stepped","Curve") var damage_falloff_method: int
export(float,-1,1) var damage_falloff_scale: float
export var damage_falloff_steps: PoolRealArray
export var damage_falloff_curve: Curve
export(int,"None","Linear","Squared","Stepped","Curve") var knockback_falloff_method: int
export(float,-1,1) var knockback_falloff_scale: float
export var knockback_falloff_steps: PoolRealArray
export var knockback_falloff_curve: Curve

signal hit(damage,knockback)
var frame_created: int
# maybe wont be used
var deletion_frame: int

onready var collisionshape: CollisionShape = $"Collision Shape"

func _init() -> void:
	connect("tree_entered",self,"on_tree_entered")
	connect("tree_exiting",self,"on_tree_exiting")
	connect("tree_exited",self,"on_tree_exited")
	frame_created = Network.get_snap_building_signature()

func _ready() -> void:
	assert(collisionshape.shape)
	if collisionshape.shape is SphereShape:
		assert(size == collisionshape.shape.radius)

func _physics_process(delta: float) -> void:
	physics_tick_server(delta) if qNetwork.is_server() else physics_tick_client(delta)
	# this is gonna bite me in the ass i know it
	if is_frame_after_created():
		queue_free()
	if !is_queued_for_deletion():
		Network.snapshot_entity(generate_snap_entity())

func physics_tick_server(delta: float) -> void:
	# hacky and stupid. checks to delete every frame. should only happen when the player disconnects
	if !Network.player_data.get_pnode(owner_id):
		queue_free()
		return
	process_inputs(Network.get_input(owner_id),is_owned_by_local_player())
	simulate(delta)

func physics_tick_client(delta: float) -> void:
	var is_local: bool = is_owned_by_local_player()
	if has_correction:
		apply_corrections()
		has_correction = false
		if is_local:
			for input in Inputs.get_local_cached_inputs():
				process_inputs(input,false)
				simulate(delta)
				Network.correct_in_snapshot(generate_snap_entity(),input)
	if is_local:
		process_inputs(Network.get_input(owner_id),true)
		simulate(delta)

func simulate(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	tick(delta,Quack.interpfrac)

func tick(delta: float, interp_frac: float) -> void:
	pass

func on_tree_entered() -> void:
	pass

func on_tree_exiting() -> void:
	pass

func on_tree_exited() -> void:
	pass

func apply_corrections() -> void:
	for correction in correction_data.keys():
		self[correction] = correction_data[correction]

func process_inputs(inputs: InputData, auth: bool) -> void:
	pass

func generate_snap_entity() -> SnapEntityBase:
	var uid: int = get_meta("uid")
	var chash: int = get_meta("chash")
	return Network.create_snap_entity(snap_entity_script,uid,chash)

func is_owned_by_local_player() -> bool:
	return Network.is_id_local(owner_id)

func is_frame_after_created() -> bool:
	return frame_created < Network.get_snap_building_signature()
