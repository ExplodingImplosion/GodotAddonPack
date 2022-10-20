extends HeldAnimTree
class_name WeaponAnimTree

const addfire: String = "Add Fire"

func fire() -> void:
	set(addfire,true)

func stop_fire() -> void:
	set(addfire,false)
