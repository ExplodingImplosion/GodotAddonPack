class_name Resources
const resource_list: Array = [
	# gameplay scenes
	[
		preload("res://Gameplay/Characters/Player Character.tscn"),
		preload("res://Gameplay/Items/Weapons/Rocket Launcher/Rocket Launcher.tscn"),
		preload("res://Gameplay/Objects/Projectiles/Rocket.tscn"),
		preload("res://Gameplay/Objects/Explosions/Rocket Explosion.tscn"),
	],
	# chashes, Quack creates this on startup
	[],
	# snap scripts, Quack creates this on startup too
	[],
	# menu names
	PoolStringArray([
		"res://Interface/Menus/Main Menu.tscn"
	]),
	# map names
	PoolStringArray([
		"res://Gameplay/Levels/Playground/Playground.tscn"
	]),
	# other scenes
	[
		
	]
]

enum {GAMEPLAYSCENES,CHASHES,SNAPSCRIPTS,MENU_NAMES,MAP_NAMES,OTHER_SCENES}
enum gameplayscenes{PlayerCharacter,RocketLauncher,Rocket,RocketExplosion}
enum chashes{}
enum snapscripts{}
enum menu_names{MainMenu}
enum map_names{PLAYGROUND}
enum other_scenes{}

static func get_gameplay_scene(idx: int) -> PackedScene:
	return resource_list[GAMEPLAYSCENES][idx]

static func get_chash(idx: int) -> int:
	return resource_list[CHASHES][idx]

static func get_snap_entity_script(idx: int) -> Script:
	return resource_list[SNAPSCRIPTS][idx]

static func get_menu_name(idx: int) -> String:
	return resource_list[MENU_NAMES][idx]

static func get_map_name(idx: int) -> String:
	return resource_list[MAP_NAMES][idx]

static func get_other_scene(idx: int) -> PackedScene:
	return resource_list[OTHER_SCENES][idx]

static func build_chashes_and_snap_scripts() -> void:
	print_debug("chashes gotta be a normal array because poolintarrays in 3.5 are limited to signed 32-bit")
	var _chashes: Array = resource_list[CHASHES]
	var _snapscripts: Array = resource_list[SNAPSCRIPTS]
	for resource in resource_list[GAMEPLAYSCENES]:
		_chashes.append((resource as PackedScene).get_path().hash())
		var dummynode: Node = (resource as PackedScene).instance()
		_snapscripts.append(dummynode.snap_entity_script)
		dummynode.queue_free()
