extends KinematicBody
class_name Projectile

# this is fucking insane but it needs to be done for bounding boxes to work because
# scritps cant pull their class name
var namehash: int = hash("ProjectileSnapData")

# is this even gonna be used?
var resource_id: int
var has_correction: bool
var owner_id: int = 1
var correction_data: Dictionary
export var snap_entity_script: Script

export(float,-100,100) var initial_speed: float
export var infinite_active_lifetime: bool
export(float,0,9223372036854775807) var active_lifetime: float
export var infinite_lifetime: bool
export(float,0,9223372036854775807) var lifetime: float
export var affected_by_gravity: bool
export(float,-100,100) var gravity: float
export var changes_velocity: bool
export(float,-100,100) var target_speed: float
export(float,0,1000) var time_to_reach_target: float
enum {DAMAGE,KNOCKBACK,SPAWN,DELETE_ON_CONTACT}
export(int,FLAGS,"Damage","Knockback","Spawn","Delete on contact") var collision_behavior: int
export(float,0,500) var damage: float
export(float,-100,100) var knockback: float
export(int,-1,999) var spawn_resource_index: int = -1
export var spawn_params: Dictionary

onready var collision_shape: CollisionShape = $"Collision Shape"
onready var mesh: MeshInstance = $Mesh

var position: Vector3
var velocity: Vector3
var orientation: Vector3

func _init() -> void:
	connect("tree_entered",self,"on_tree_entered")
	connect("tree_exiting",self,"on_tree_exiting")
	connect("tree_exited",self,"on_tree_exited")
#	if collision_damages():
#		pass

func _ready() -> void:
	pass

signal collided(dmg,kb)

func _physics_process(delta: float) -> void:
	physics_tick_server(delta) if qNetwork.is_server() else physics_tick_client(delta)
	if !is_queued_for_deletion():
		Network.snapshot_entity(generate_snap_entity())

func physics_tick_server(delta: float) -> void:
	# hacky and stupid. checks to delete every frame. should only happen when the player disconnects
	if !Network.player_data.get_pnode(owner_id):
		queue_free()
		return
	process_inputs(Network.get_input(owner_id),is_owned_by_local_player())
	simulate(delta)
	if owner_id != 1:
		bbox_test()

func bbox_test() -> void:
	var intersections: Array = BoundingBox.test(params)
	for intersection in intersections:
		if intersection is BoundingBox:
			intersection.on_body_entered(self)

onready var params: PhysicsShapeQueryParameters = BoundingBox.setup_params([self],collision_shape)
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
	var collision: KinematicCollision = move(delta)
	if collision:
		# could be something else like a csg mesh
		var collider: Spatial = collision.get_collider()
		if Collision.collides_with_world(collider):
			if collision_damages():
				if Collision.is_damageable(collider):
					pass
			if collision_knockbacks():
				if Collision.accepts_knockback(collider):
					pass
			# spawn node if should
			if collision_spawns() and spawn_resource_index > -1:
				Entity.try_spawn_node(spawn_resource_index,owner_id,spawn_params,self)
			# delete self if should
			if delete_on_contact():
				# maybe not
				queue_free()
	position = global_transform.origin
	orientation = global_rotation

func move(delta: float) -> KinematicCollision:
	var speed: float = initial_speed
	if changes_velocity:
		pass
	if affected_by_gravity:
		pass
	velocity = (-global_transform.basis.z).normalized() * speed
	return move_and_collide(velocity * delta)

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
	global_rotation = orientation
	global_transform.origin = position

func process_inputs(inputs: InputData, auth: bool) -> void:
	pass

func generate_snap_entity() -> SnapEntityBase:
	var uid: int = get_meta("uid")
	var chash: int = get_meta("chash")
	return Network.create_snap_entity(snap_entity_script,uid,chash)

func is_owned_by_local_player() -> bool:
	return Network.is_id_local(owner_id)

func collision_damages() -> bool:
	return collision_behavior && DAMAGE

func collision_knockbacks() -> bool:
	return collision_behavior && KNOCKBACK

func collision_spawns() -> bool:
	return collision_behavior && SPAWN

func delete_on_contact() -> bool:
	return collision_behavior && DELETE_ON_CONTACT
