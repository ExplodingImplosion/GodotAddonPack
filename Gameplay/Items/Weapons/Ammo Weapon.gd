extends Weapon
class_name AmmoWeapon

export(int,1,100) var ammo_used_per_shot: int = 1
export(int,1,100) var mag_size: int
export(int,1,100) var ammo_per_load: int
export(float,0,10) var reload_time: float
export(float,0,10) var chamber_time: float
export var reload_sound: AudioStreamSample

var current_ammo: int
var reload_time_left: float
var chamber_time_left: float
var reloading: bool
var rechambering: bool

signal reload_finished
signal ammo_chambered
signal ammo_reloaded

onready var reload_timer: CustomTimer = CustomTimer.new(reload_time,false)
onready var chamber_timer: CustomTimer = CustomTimer.new(chamber_time,false)

func _ready() -> void:
	._ready()
	reload_timer.connect("finished",self,"on_reload_finished")
	chamber_timer.connect("finished",self,"on_ammo_chambered")

func simulate(delta: float) -> void:
	.simulate(delta)
	if is_reloading():
		reload_timer.tick(delta)
	if is_ammo_rechambering():
		chamber_timer.tick(delta)
	reloading = is_reloading()
	rechambering = is_ammo_rechambering()
	reload_time_left = reload_timer.time_left
	chamber_time_left = chamber_timer.time_left

func apply_corrections() -> void:
	.apply_corrections()
	reload_timer.time_left = reload_time_left
	chamber_timer.time_left = chamber_time_left
	reload_timer.is_running = reloading
	chamber_timer.is_running = rechambering

func input3() -> void:
	try_reload()

func has_ammo() -> bool:
	return current_ammo > 0

func is_mag_empty() -> bool:
	return current_ammo <= 0

func is_fireable() -> bool:
	return .is_fireable() and has_ammo()

func fire() -> void:
	.fire()
	current_ammo -= ammo_used_per_shot

func can_reload() -> bool:
	return current_ammo < mag_size and !is_reloading() and !equipping and not fired

func is_reloading() -> bool:
	return reload_timer.is_running

func is_ammo_rechambering() -> bool:
	return chamber_timer.is_running

func begin_reload() -> void:
	can_fire = false
	reload_timer.start()
	chamber_timer.start()
func try_reload() -> void:
	if can_reload():
		begin_reload()

func on_ammo_chambered(time_remainder: float, interp_fraction: float) -> void:
	current_ammo += ammo_per_load
	if current_ammo > mag_size:
		current_ammo = mag_size
	elif current_ammo < mag_size:
		begin_reload()

func on_reload_finished(remainder: float, interp_fraction: float) -> void:
	can_fire = true

func on_equip_finished(remainder: float, interp_fraction: float) -> void:
	.on_equip_finished(remainder,interp_fraction)
	reload_if_empty()

func on_tree_entered() -> void:
	.on_tree_entered()
	current_ammo = mag_size

func reload_if_empty() -> void:
	if is_mag_empty():
		begin_reload()

func on_attack_cycled(remainder: float, interp_fraction: float) -> void:
	.on_attack_cycled(remainder,interp_fraction)
	reload_if_empty()
