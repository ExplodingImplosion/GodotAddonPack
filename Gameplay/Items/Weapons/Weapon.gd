extends Held
class_name Weapon

export(float,0,10) var fire_rate: float
export(float,0,10) var cycle_rate: float
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
var cycled: bool
var can_fire: bool
var trying_to_fire: bool
var released_fire: bool
var fired: bool

onready var fire_timer: CustomTimer = CustomTimer.new(fire_rate,false)
onready var cycle_timer: CustomTimer = CustomTimer.new(cycle_rate,false)

signal shot_fired(interpfrac)

func _ready() -> void:
	._ready()
	fire_timer.connect("finished",self,"on_attack_cycled")

func simulate(delta: float) -> void:
	.simulate(delta)
	if fired:
		fire_timer.tick(delta)

func try_fire() -> void:
	trying_to_fire = true
	if is_fireable():
		fire()
	
func fire() -> void:
	can_fire = false
	cycled = false
	released_fire = false
	# maybe make it 0
	emit_signal("shot_fired",Quack.interpfrac)
	#fire_timer.start()
	if firing_sound:
		pass
		#Audio.play(firing_sound,volume,max_volume,pitch_scale)
	try_spawn_node(spawn_resource_index,owner_id,spawn_params,self)
	fired = true
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
	pass
