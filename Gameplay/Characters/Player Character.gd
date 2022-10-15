extends KinematicBody
class_name PlayerCharacter

# this is fucking insane but it needs to be done for bounding boxes to work because
# scritps cant pull their class name
var namehash: int = hash("PlayerSnapData")

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
onready var collision_shape: CollisionShape = $CollisionShape
onready var size: Vector3 = get_size()
#onready var boundingbox: BoundingBox = qNetwork.try_make_bbox(self,Entity.get_collision_dimensions(collision_shape))

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
	var shape: CapsuleShape = collision_shape.shape
	return Vector3(shape.radius,shape.height,shape.radius)*2

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
	update_aim_angle()
	if has_correction:
		# only applying corrections if correction data is the same as
		# current info doesnt work because of floating point imprecision :/
		# would need to either take every float for both dicts and quantize them
		# or something or instead of hashing the dicts, this would go through every
		# single fucking key and compare them, and specifically compare using
		# is_equal_approx based on what type each value is... Would like to use this
		# as an optimization so that rolling back only occurs when client/server
		# disagree but we live in a cruel world i guess 
#		var altdata: Dictionary = generate_snap_entity().make_correction_data()
#		if altdata.hash() != correction_data.hash():
#			if Engine.get_physics_frames() % 60 == 0:
#				prints(altdata.hash(),correction_data.hash())
#				prints("altadata keys ",altdata.keys().size()," correction_data keys ",correction_data.keys().size())
#				for key in altdata.keys():
#					prints(altdata[key],correction_data[key],altdata[key] == correction_data[key])
#					print("---")
		var caim: Vector2 = aim_angle
		apply_corrections()
		has_correction = false
		if is_local:
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

static func defaultinventory() -> Array:
	var i: Array
	i.resize(3)
	return i

enum {NOITEM = -1}
var current_item: Held
var current_item_idx: int = -1
var inventory: Array = defaultinventory()

func inventory_has_empty_slot() -> int:
	return inventory.find(null)

func insert_item(item: Held, idx: int) -> void:
	inventory[idx] = item

func exchange_current_item_for_new(item: Held) -> void:
	current_item.drop()
	inventory[current_item_idx] = item
	set_item_current(item)

func set_item_current(item: Held) -> void:
	current_item = item
	current_item.equip()

# WEAPON STUFF
func give_held_item(item: Held) -> void:
	var empty_idx: int = inventory_has_empty_slot()
	if empty_idx > NOITEM:
		assert(!item.equipped)
		insert_item(item,empty_idx)
		# change at some point so that players can choose to have all items
		# unequipped
		if current_item_idx == NOITEM:
			set_item_current(item)
	else:
		assert(current_item_idx > NOITEM and current_item != null)
		exchange_current_item_for_new(item)
	qNetwork.map.reparent_node(item,self)
