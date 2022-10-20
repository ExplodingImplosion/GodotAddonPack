extends Held
class_name Weapon

export(float,0,10) var fire_rate: float
#export(float,0,10) var cycle_rate: float
export(int,-1,999) var spawn_resource_index: int = -1
export var spawn_params: Dictionary
export var can_headshot: bool
export(float,0,100) var headshot_multiplier: float
enum {AUTO,SINGLE,PUMPBOLT}
export(int,"Automatic","Single","Pump/Bolt") var firing_type: int
export var firing_sound: AudioStreamSample
export(float,-10,10) var volume: float
export(float,-10,10) var max_volume: float
export(float,-10,10) var pitch_scale: float = 1

var fire_time_left: float
#var cycled: bool
var can_fire: bool
var trying_to_fire: bool
var released_fire: bool
var fired: bool

var sim_authority: bool

onready var fire_timer: CustomTimer = CustomTimer.new(fire_rate,false)
#onready var cycle_timer: CustomTimer = CustomTimer.new(cycle_rate,false)

signal shot_fired(interpfrac)

func _ready() -> void:
	fire_timer.connect("finished",self,"on_attack_cycled")

func simulate(delta: float) -> void:
	.simulate(delta)
	if fired:
		fire_timer.tick(delta)
	fired = fire_timer.is_running
	fire_time_left = fire_timer.time_left

func apply_corrections() -> void:
	.apply_corrections()
	fire_timer.time_left = fire_time_left
	fire_timer.is_running = fired

func try_fire() -> void:
	trying_to_fire = true
	if is_fireable():
		fire()

func process_inputs(inputs: InputData, auth: bool) -> void:
	.process_inputs(inputs,auth)
	sim_authority = auth
	if !inputs.is_pressed("fire"):
		released_fire = true
		trying_to_fire = false

func fire() -> void:
	can_fire = false
#	cycled = false
	fired = true
	released_fire = false
	# maybe make it 0
	emit_signal("shot_fired",Quack.interpfrac)
	#fire_timer.start()
	if firing_sound:
		pass
		#Audio.play(firing_sound,volume,max_volume,pitch_scale)
	if sim_authority:
		try_spawn_node(spawn_resource_index,owner_id,spawn_params,self)
	fire_timer.start()
	

func is_fireable() -> bool:
#	if firing_type == AUTO || released_fire:
#		return can_fire
#	else:
#		return false
	return (firing_type == AUTO or released_fire) and can_fire

func try_ads() -> void:
	pass
func ads() -> void:
	pass

func input1() -> void:
	try_fire()

func input2() -> void:
	try_ads()

#func input3() -> void:
#	try_reload()

func on_equip_finished(remainder: float, interp_fraction: float) -> void:
	.on_equip_finished(remainder,interp_fraction)
	can_fire = true

#func simulate(delta: float) -> void:
#	.simulate(delta)

func on_attack_cycled(remainder: float, interp_fraction: float) -> void:
	can_fire = true
	try_refire(remainder,interp_fraction)

func try_refire(remainder: float, interp_fraction: float) -> void:
	if trying_to_fire and is_fireable():
		fire()
		assert(remainder > -0.0)
		fire_timer.tick(remainder)
