extends Held
class_name Weapon

export(float,0,10) var fire_rate: float
export(float,0,100) var damage: float
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

signal shot_fired(interpfrac)

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

func on_equip_finished() -> void:
	.on_equip_finished()
	can_fire = true
