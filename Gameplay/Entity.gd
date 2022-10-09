extends Spatial
class_name Entity

# this is fucking insane but it needs to be done for bounding boxes to work because
# scritps cant pull their class name
var namehash: int = hash("EntitySnapData")

var resource_id: int
var has_correction: bool
var owner_id: int = 1
var correction_data: Dictionary
export var snap_entity_script: Script

func _init() -> void:
# warning-ignore:return_value_discarded
	connect("tree_entered",self,"on_tree_entered")
# warning-ignore:return_value_discarded
	connect("tree_exiting",self,"on_tree_exiting")
# warning-ignore:return_value_discarded
	connect("tree_exited",self,"on_tree_exited")

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
# warning-ignore:standalone_ternary
	physics_tick_server(delta) if qNetwork.is_server() else physics_tick_client(delta)
	if !is_queued_for_deletion():
		Network.snapshot_entity(generate_snap_entity())

func physics_tick_server(delta: float) -> void:
	# hacky and stupid. checks to delete every frame. should only happen when the player disconnects
	if !Network.player_data.get_pnode(owner_id):
		queue_free()
		return
	process_inputs(Network.get_input(owner_id),is_owned_by_local_player())
	simulate(delta)

func physics_tick_client(delta: float) -> void:
	var is_local: bool = is_owned_by_local_player()
	if has_correction:
		apply_corrections()
		has_correction = false
		if is_local:
			for input in Inputs.get_local_cached_inputs():
				process_inputs(input,false)
				simulate(delta)
				Network.correct_in_snapshot(generate_snap_entity(),input)
	if is_local:
		process_inputs(Network.get_input(owner_id),true)
		simulate(delta)

# warning-ignore:unused_argument
func simulate(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	tick(delta,Quack.interpfrac)

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func tick(delta: float, interp_frac: float) -> void:
	pass

func on_tree_entered() -> void:
	pass

func on_tree_exiting() -> void:
	pass

func on_tree_exited() -> void:
	pass

func apply_corrections() -> void:
	for correction in correction_data.keys():
		self[correction] = correction_data[correction]

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func process_inputs(inputs: InputData, auth: bool) -> void:
	pass

func generate_snap_entity() -> SnapEntityBase:
	var uid: int = get_meta("uid")
	var chash: int = get_meta("chash")
	return Network.create_snap_entity(snap_entity_script,uid,chash)

func is_owned_by_local_player() -> bool:
	return Network.is_id_local(owner_id)

static func get_entity_from_snapshot(snapshot: NetSnapshot, entity: Spatial) -> SnapEntityBase:
	return snapshot.get_entity(entity.namehash,entity.owner_id)
