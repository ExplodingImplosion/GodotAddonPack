extends AmmoWeapon
class_name SingleLoader

export(int,1,100) var ammo_per_load: int

func on_ammo_chambered() -> void:
	current_ammo += ammo_per_load
	if current_ammo > mag_size:
		current_ammo = mag_size
	elif current_ammo < mag_size:
		begin_reload()

#func is_chambered() -> bool:
#	return has_ammo()

#func is_reloading() -> bool:
#	return # is_chambering ammo

func fire() -> void:
	.fire()
	# stop chambering ammo
