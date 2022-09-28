extends Spatial
class_name Map

export(int, 0, 99) var max_players: int = 0
export(int,"Default") var default_gamemode: int = 0

export var icon: Texture
export var radar_image: Texture
export var environment: Environment
export var out_of_bounds_distance: float = 1000.0

export var preferred_spawns := []

static func map_path_from_name(mapname: String) -> String:
	return "res://Gameplay/Levels/%s/%s.tscn"%[mapname,mapname]

static func map_name_from_path(path: String) -> String:
	return path.split("Levels/")[1].split(".tscn")[0]

func _init() -> void:
	pass

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func reparent_node(node: Node,to: Node) -> void:
	remove_child(node)
	to.add_child(node)
