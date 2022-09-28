extends AmmoWeapon
class_name SingleLoader

#func is_chambered() -> bool:
#	return has_ammo()

#func is_reloading() -> bool:
#	return # is_chambering ammo

func fire() -> void:
	.fire()
	# stop chambering ammo
