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
export var damage_falloff_step_distances: PoolRealArray
export var damage_falloff_curve: Curve
export(int,"None","Linear","Squared","Stepped","Curve") var knockback_falloff_method: int
export(float,-1,1) var knockback_falloff_scale: float
export var knockback_falloff_steps: PoolRealArray
export var knockback_falloff_curve: Curve

signal hit(damage,knockback)
var frame_created: int
# maybe wont be used
var deletion_frame: int
var position: Vector3

onready var collision_shape: CollisionShape = $"Collision Shape"
#onready var boundingbox: BoundingBox = qNetwork.try_make_bbox(self,Entity.get_collision_dimensions(collision_shape))

func _init() -> void:
	connect("tree_entered",self,"on_tree_entered")
	connect("tree_exiting",self,"on_tree_exiting")
	connect("tree_exited",self,"on_tree_exited")
	frame_created = Network.get_snap_building_signature()

func _ready() -> void:
	assert(collision_shape.shape)
	if collision_shape.shape is SphereShape:
		assert(size == collision_shape.shape.radius)

func _physics_process(delta: float) -> void:
	physics_tick_server(delta) if qNetwork.is_server() else physics_tick_client(delta)
	# this is gonna bite me in the ass i know it
	if is_frame_after_created():
		prints("deleting explosion",self,frame_created,Network.get_snap_building_signature())
		Entity.despawn(self,get_meta("uid"))
	if !is_queued_for_deletion():
		Network.snapshot_entity(generate_snap_entity())

func physics_tick_server(delta: float) -> void:
	# hacky and stupid. checks to delete every frame. should only happen when the player disconnects
	if !Network.player_data.get_pnode(owner_id):
		Entity.despawn(self,get_meta("uid"))
		return
	process_inputs(Network.get_input(owner_id),is_owned_by_local_player())
	simulate(delta)
	if owner_id != 1:
		#	var intersections: Array = Collision.test(params)
		for intersection in Collision.test(bbox_params):
			if intersection.collider is BoundingBox:
				intersection.collider.on_body_entered(self)

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

onready var bbox_params: PhysicsShapeQueryParameters = BoundingBox.setup_params([self],collision_shape)
onready var collision_params: PhysicsShapeQueryParameters = Collision.setup_params([self],collision_shape,collision_mask,true,false)
func simulate(delta: float) -> void:
	position = global_transform.origin
	for intersection in Collision.test(collision_params,900):
		print(intersection.collider)
		assert(intersection.collider is Spatial and not intersection.collider is Area)
		on_body_entered(intersection.collider)

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
	global_transform.origin = position

func process_inputs(inputs: InputData, auth: bool) -> void:
	pass

func generate_snap_entity() -> SnapEntityBase:
	var uid: int = get_meta("uid")
	var chash: int = get_meta("chash")
	var data: SnapEntityBase = Network.create_snap_entity(snap_entity_script,uid,chash)
	data.get_vars(self)
	return data

func is_owned_by_local_player() -> bool:
	return Network.is_id_local(owner_id)

func is_frame_after_created() -> bool:
	return frame_created < Network.get_snap_building_signature()

func on_body_entered(body: Spatial):
	if Collision.can_damage_happen(self,body):
		body.apply_damage(get_damage(body))
	if Collision.can_knockback_happen(self,body):
		body.apply_knockback(get_knockback(body))

func get_damage(body: Spatial) -> float:
	assert_is_valid_method(damage_falloff_method)
	match damage_falloff_method:
		NONE:
			return damage
		LINEAR:
			pass
		SQUARED:
			pass
		STEPPED:
			pass
		CURVE:
			pass
	return damage

static func get_distance(n1: Spatial, n2: Spatial) -> float:
	return n1.global_transform.origin.distance_to(n2.global_transform.origin)

static func get_size_normalized_distance(n1: Explosion, n2: Spatial) -> float:
	return get_distance(n1,n2) / n1.size

static func assert_is_valid_method(method: int) -> void:
	assert(method >= NONE and method <= CURVE)

func get_knockback(body: Spatial) -> Vector3:
	assert_is_valid_method(knockback_falloff_method)
#	var kb: float = knockback
	match knockback_falloff_method:
		NONE:
			return get_knockback_from_relative(self,body,knockback)
		LINEAR:
			pass
		SQUARED:
			pass
		STEPPED:
			pass
		CURVE:
			pass
	return get_knockback_from_relative(self,body,knockback)

static func get_knockback_from_relative(n1: Spatial, n2: Spatial, amount: float) -> Vector3:
	n1.look_at(n2.global_transform.origin,Vector3.UP)
	return (-n1.global_transform.basis.z).normalized() * amount
