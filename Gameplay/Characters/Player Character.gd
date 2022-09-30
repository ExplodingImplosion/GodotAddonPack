extends KinematicBody
class_name PlayerCharacter

var resource_id: int = 0

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
export var snap_entity_script: Script
var correction_data: Dictionary
var has_correction: bool

# NODE REFERENCES
onready var head: Spatial = $Head
onready var camera: Camera = $Head/Camera
onready var collisionshape: CollisionShape = $CollisionShape
onready var size: Vector3 = get_size()
onready var boundingbox: BoundingBox = $"Spatial/Bounding Box"

# EXPORT VARS
export var speed: float = 7.0
export var mod_movement_speed_factor: float = 1.2
export var mod_movement_acceleration_factor: float = 0.7
export var acceleration: float = 1.5
export var friction: float = 26.0
export var air_control: float = 7.0
export var jump_strength: float = 10.0
export var gravity: float = 9.8
export var terminal_velocity: float = 60.0
export var crouch_movement_speed_factor: float = 3.0
export var crouch_acceleration_factor: float = 1.0
export var crouch_speed: float = 2.0
export var standing_height: float = 1.88
export var crouching_height: float = 1.0

func get_size() -> Vector3:
	var shape: CapsuleShape = collisionshape.shape
	return Vector3(shape.radius,shape.height,shape.radius)

func _init() -> void:
	pass
func _ready() -> void:
	owner_id = get_meta("uid") if has_meta("uid") else 1
	if is_owned_by_local_player():
		camera.set_current(true)
		Quack.capture_cursor()
# warning-ignore:return_value_discarded
		Inputs.connect("mouse_moved",self,"aim")
	

func _process(delta: float) -> void:
	tick(delta,Quack.interpfrac)
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func tick(delta: float, interp_frac: float) -> void:
	pass

func _physics_process(delta: float) -> void:
# warning-ignore:standalone_ternary
	physics_tick_server(delta) if qNetwork.is_server() else physics_tick_client(delta)
	# this is hacky and stupid
	if !is_queued_for_deletion():
		Network.snapshot_entity(generate_snap_entity())

func physics_tick_client(delta: float) -> void:
	var is_local: bool = is_owned_by_local_player()
	if has_correction:
		apply_corrections()
		has_correction = false
		if is_local:
			update_aim_angle()
			var caim: Vector2 = aim_angle
			for input in Inputs.get_local_cached_inputs():
				process_inputs(input,false)
				simulate(delta)
				Network.correct_in_snapshot(generate_snap_entity(),input)
			set_aim(caim)
	if is_local:
		process_inputs(Network.get_input(owner_id),true)
		simulate(delta)

func physics_tick_server(delta: float) -> void:
	# hacky and stupid. checks to delete every frame. should only happen when the player disconnects
	if !Network.player_data.get_pnode(owner_id):
		queue_free()
		return
	process_inputs(Network.get_input(owner_id),is_owned_by_local_player())
	simulate(delta)

func generate_snap_entity() -> SnapEntityBase:
	var uid: int = get_meta("uid")
	var chash: int = get_meta("chash")
	var data: SnapEntityBase = Network.create_snap_entity(snap_entity_script,uid,chash)
	data.get_vars(self)
	return data

func is_owned_by_local_player() -> bool:
	return Network.is_id_local(owner_id)

func simulate(delta: float) -> void:
	move(delta)

var direction: Vector3
var temp_vel: Vector3
var temp_accel: float
var target: Vector3
func move(delta: float) -> void:
	direction = (global_transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	temp_vel = Vector3(velocity.x,0,velocity.z)
	target = direction * speed
	if is_on_floor():
		if direction:
			temp_accel = acceleration * friction
		else:
			temp_accel = friction
		if jumped:
			velocity.y += jump_strength
	else:
		if direction.dot(velocity) > 0:
			temp_accel = air_control
		else:
			temp_accel = 0
		# apply gravity up until terminal velocity
		if velocity.y >= -terminal_velocity:
			velocity.y = clamp(velocity.y - gravity * delta,-terminal_velocity,velocity.y)
	temp_vel = temp_vel.move_toward(target,temp_accel*delta)
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	velocity = move_and_slide(velocity,Vector3.UP)

const max_vertical_aim_angle: float = 89.999
const min_vertical_aim_angle: float = -max_vertical_aim_angle

func aim(relative: Vector2) -> void:
	rotation_degrees.y -= relative.x
	head.rotation_degrees.x = clamp(head.rotation_degrees.x-relative.y,min_vertical_aim_angle,max_vertical_aim_angle)
	

func set_aim(angle: Vector2) -> void:
	rotation_degrees.y = angle.x
	head.rotation_degrees.x = angle.y

func update_aim_angle() -> void:
	aim_angle = Vector2(rotation_degrees.y,head.rotation_degrees.x)

func apply_corrections() -> void:
	for correction in correction_data.keys():
		self[correction] = correction_data[correction]
	set_aim(aim_angle)
	global_transform.origin = position

var just_jumped: bool = false
var jumped: bool = false
#var movement_mod: float = 1.0
#var crouch_mod: float = 1.0
func process_inputs(input_data: InputData,auth: bool) -> void:
	if !input_data:
		return
	var inputted_jump: bool =  input_data.is_pressed("jump")
#	jumped = !just_jumped and inputted_jump
#	just_jumped = inputted_jump
	jumped = inputted_jump
	
#	crouch_mod = float(input_data.is_pressed("crouch"))
#	movement_mod = float(input_data.is_pressed("modify_movement"))
	if auth:
		update_aim_angle()
		input_data.set_custom_vec2("aim_angle",aim_angle)
		input_dir = Inputs.get_movement_from_keyboard()
		input_data.set_custom_vec2("input_dir",input_dir)
	else:
		aim_angle = input_data.get_custom_vec2("aim_angle")
		set_aim(aim_angle)
		input_dir = input_data.get_custom_vec2("input_dir")
