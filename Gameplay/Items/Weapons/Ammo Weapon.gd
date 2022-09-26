extends Weapon
class_name AmmoWeapon

export(int,1,100) var ammo_used_per_shot: int = 1
export(int,1,100) var mag_size: int
export(float,0,10) var reload_time: float
export(float,0,10) var chamber_time: float
export var reload_sound: AudioStreamSample

var current_ammo: int
var reload_time_left: float
var chamber_time_left: float

signal reload_finished
signal ammo_chambered
signal ammo_reloaded

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
	return current_ammo < mag_size and !is_reloading() and !is_equipping() and not fired

func is_reloading() -> bool:
	return false

func begin_reload() -> void:
	can_fire = false
func try_reload() -> void:
	pass

func on_ammo_chambered() -> void:
	current_ammo = mag_size

func on_reload_finished() -> void:
	can_fire = true

func on_equip_finished() -> void:
	.on_equip_finished()
	if is_mag_empty():
		begin_reload()
