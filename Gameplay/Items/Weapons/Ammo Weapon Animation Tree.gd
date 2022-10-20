extends WeaponAnimTree
class_name AmmoWeaponAnimTree

const reloadoridle: String = "Reload or Idle"

func reload() -> void:
	set(reloadoridle,true)

func stop_reload() -> void:
	set(reloadoridle,false)
