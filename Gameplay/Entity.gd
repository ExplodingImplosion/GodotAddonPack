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
		despawn(self,get_meta("uid"))
		return
	process_inputs(Network.get_input(owner_id),is_owned_by_local_player())
	simulate(delta)

func physics_tick_client(delta: float) -> void:
	var is_local: bool = is_owned_by_local_player()
	if has_correction:
#		if generate_snap_entity().make_correction_data().hash() != correction_data:
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
	var data: SnapEntityBase = Network.create_snap_entity(snap_entity_script,uid,chash)
	data.get_vars(self)
	return data

func is_owned_by_local_player() -> bool:
	return Network.is_id_local(owner_id)

static func get_entity_from_snapshot(snapshot: NetSnapshot, entity: Spatial) -> SnapEntityBase:
	return snapshot.get_entity(entity.namehash,entity.owner_id)

static func spawn_params_to_correction_data(entity: Spatial, params: Dictionary) -> Dictionary:
	var ret: Dictionary
	for key in params.keys():
		assert(key is String and params[key] is NodePath)
		var param: NodePath = params[key]
		ret[key] = entity.get_node(param)[key]
	return ret

static func try_spawn_node(_spawn_resource_index: int, _owner_id: int, _spawn_params: Dictionary, from: Spatial) -> void:
	assert(_spawn_resource_index > -1)
	var node: Node = qNetwork.spawn_node_by_resource_idx(_spawn_resource_index,qNetwork.get_player_current_snap_sig(_owner_id))
	prints(node,node.get_meta("uid"))
	var correction_data: Dictionary = spawn_params_to_correction_data(from,_spawn_params)
	for key in correction_data.keys():
#			assert(node.correction_data.has(key))
#			assert(typeof(node.correction_data[key]) == typeof(correction_data[key]))
		node.correction_data[key] = correction_data[key]
	node.apply_corrections()
	node._physics_process(node.get_physics_process_delta_time())

static func despawn(node: Spatial,node_id: int) -> void:
	Network.snapshot_data.despawn_node(node.snap_entity_script,node_id)
