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
export(int,0,999) var dropped_resource_index: int

var equipped: bool
var equipping: bool
var equip_time_left: float
var sway: Vector3
#var sway_should_return: bool
var player: KinematicBody
onready var rotational_parent: Position3D = $"Rotational Parent"
onready var offset: Position3D = $Offset
onready var mesh: MeshInstance = $"Rotational Parent/Item Mesh"
onready var equip_timer: CustomTimer = CustomTimer.new(equip_time,false)

func _init() -> void:
	._init()

func _ready() -> void:
	._ready()
	assert(equip_timer.max_time == equip_time and equip_time == equip_timer.time_left)
	connect_sway_to_mouse_movement_if_local()
	equip_timer.connect("finished",self,"on_equip_finished")

func connect_sway_to_mouse_movement_if_local() -> void:
	if is_owned_by_local_player():
		Inputs.connect_to_mouse_movement_if_not_already(self,"modify_sway")

func apply_corrections() -> void:
	.apply_corrections()
	connect_sway_to_mouse_movement_if_local()
	equip_timer.time_left = equip_time_left
	equip_timer.is_running = equipping

func on_tree_entered() -> void:
	# not optimized and high key stupid
	var parent: Node = get_parent()
	if parent and parent is KinematicBody:
		player = parent
		parent.remove_child(self)
		parent.head.add_child(self)

func _physics_process(delta: float) -> void:
	offset.update()

func input1() -> void:
	pass

func input2() -> void:
	pass

func input3() -> void:
	pass

func on_equip_finished(remainder: float, interp_fraction: float) -> void:
	pass

func equip() -> void:
	equipped = true
	equip_timer.start()
	equipping = true
#	show()

func unequip() -> void:
	if equipping:
		equipping = false
	equipped = false
	equip_timer.stop()

func drop() -> void:
	queue_free()

func tick_sway(delta: float) -> void:
	update_sway()
#	if sway_should_return:
	tick_sway_return(delta)
#	else:
#		sway_should_return = true

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
	sway.x = clamp(sway.x + (direction.y * vertical_sway_factor),-max_vertical_sway,max_vertical_sway)
	sway.y = clamp(sway.y + (direction.x * horizontal_sway_factor),-max_horizontal_sway,max_horizontal_sway)
	sway.z = clamp(sway.z + (direction.x * tilt_factor),-max_tilt,max_tilt)
#	sway_should_return = false

func modify_tilt_from_movement(value: float) -> void:
	sway.z += value * movement_tilt_factor

func simulate(delta: float) -> void:
	if equipped:
		tick_sway(delta)
		if equipping:
			equip_timer.tick(delta)
	equip_time_left = equip_timer.time_left
	equipping = equip_timer.is_running

func process_inputs(inputs: InputData, auth: bool) -> void:
	if inputs.is_pressed("fire"):
		input1()
	if inputs.is_pressed("alt_fire"):
		input2()
	if inputs.is_pressed("reload"):
		input3()
