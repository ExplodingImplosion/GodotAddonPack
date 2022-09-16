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

# EXPORT VARS
export var speed: float = 7.0
export var mod_movement_speed_factor: float = 1.0
export var mod_movement_acceleration_factor: float = 1.0
export var acceleration: float = 2.1
export var friction: float = 10.0
export var air_control: float = 1.0
export var jump_strength: float = 10.0
export var gravity: float = 9.8
export var terminal_velocity: float = 60.0
export var crouch_movement_speed_factor: float = 3.0
export var crouch_acceleration_factor: float = 1.0
export var crouch_speed: float = 2.0
export var standing_height: float = 1.88
export var crouching_height: float = 1.0

func _init() -> void:
	pass
func _ready() -> void:
	owner_id = get_meta("uid")
	if is_owned_by_local_player():
		camera.set_current(true)
		Quack.capture_cursor()
		Inputs.connect("mouse_moved",self,"aim")

func _process(delta: float) -> void:
	pass
func _physics_process(delta: float) -> void:
	if has_correction:
		apply_corrections()
		if is_owned_by_local_player():
			for input in get_local_cached_inputs():
				process_inputs(input)
				Network.correct_in_snapshot(generate_snap_entity(),input)
	physics_tick_server(delta) if qNetwork.is_server() else physics_tick_client(delta)
	# might need to be auth exclusive
	Network.snapshot_entity(generate_snap_entity())

func physics_tick_client(delta: float) -> void:
	if is_owned_by_local_player():
		process_inputs(Network.get_input(owner_id))
		move(delta)

func physics_tick_server(delta: float) -> void:
	process_inputs(Network.get_input(owner_id))
	move(delta)

func generate_snap_entity() -> SnapEntityBase:
#	var uid: int
	var data: SnapEntityBase = Network.create_snap_entity(snap_entity_script,get_meta("uid"),0)
	data.get_vars(self)
	return data

func is_owned_by_local_player() -> bool:
	return Network.get_local_id() == owner_id

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
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x-relative.y,min_vertical_aim_angle,max_vertical_aim_angle)
	

func set_aim(angle: Vector2) -> void:
	rotation_degrees.y = angle.x
	camera.rotation_degrees.y = angle.y

func apply_corrections() -> void:
	for correction in correction_data.keys():
		self[correction] = correction_data[correction]

var just_jumped: bool = false
var jumped: bool = false
#var movement_mod: float = 1.0
#var crouch_mod: float = 1.0
func process_inputs(input_data: InputData) -> void:
	if !input_data:
		return
	var inputted_jump: bool =  input_data.is_pressed("jump")
	jumped = !just_jumped and inputted_jump
	just_jumped = inputted_jump
#	crouch_mod = float(input_data.is_pressed("crouch"))
#	movement_mod = float(input_data.is_pressed("modify_movement"))
	if is_owned_by_local_player():
		input_data.set_custom_vec2("aim_angle",aim_angle)
		input_dir = Inputs.get_movement_from_keyboard()
		input_data.set_custom_vec2("input_dir",input_dir)

func get_local_cached_inputs() -> Array:
	return Network.player_data.local_player.get_cached_input_list()
