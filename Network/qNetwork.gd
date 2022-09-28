extends Node

const localhost = 'localhost'
enum {DEFAULT_PORT = 25565, DEFAULT_BROWSER_PORT = 42069, DEFAULT_LOCAL_BROWSER_PORT = 25566}
var map: Map
var map_path: String
var max_players: int
var max_spectators: int
var local_player: NetPlayerNode

# MAP STUFF
# ////////////////////////////////////
func setup_map(map_filepath: String) -> void:
	map_path = map_filepath
	Quack.change_scene(map_filepath)
	print(map_filepath)
	call_deferred("apply_map")
func apply_map() -> void:
	map = get_tree().current_scene
func clear_map() -> void:
	map.queue_free()
	map = null
# ////////////////////////////////////

# should be puppet
remote func client_start(path: String) -> void:
	if is_client():
		setup_map(path)
		call_deferred("start")

func start() -> void:
	Inputs.register_all_actions()
	Inputs.register_custom_input_stuff()
	register_all_spawners()
	assign_local_player()
	if is_client():
		# maybe do on both?
		Network.notify_ready()
#	if is_server():
	else:
		try_respawning_player(1)
	set_physics_process(true)
#	Network.connect("",self,"")
#	Network.connect("",self,"")
#	Network.connect("",self,"")
	#chat_message_received
	#ping_updated
	#player_added
	#server_created
	#server_creation_failed
	#credentials_requested
	#custom_property_changed

func assign_local_player() -> void:
	local_player = Network.player_data.get_pnode(Network.player_data.local_player.net_id)

func setup_connections() -> void:
# warning-ignore:return_value_discarded
	Network.connect("player_added",self,"on_player_added")
# warning-ignore:return_value_discarded
	Network.connect("player_removed",self,"on_player_removed")
# warning-ignore:return_value_discarded
	Network.connect("join_accepted",self,"on_connection_succeeded")
# warning-ignore:return_value_discarded
	Network.connect("join_fail",self,"on_join_failed")
# warning-ignore:return_value_discarded
	Network.connect("join_rejected",self,"on_join_rejected")
# warning-ignore:return_value_discarded
	Network.connect("kicked",self,"on_kicked")

func _init() -> void:
	setup_connections()
func _ready() -> void:
	set_physics_process(false)


# SPAWNER STUFF
# ////////////////////////////////////

func register_all_spawners() -> void:
	register_spawner(PlayerSnapData, Resources.gameplayscenes.PlayerCharacter, Resources.chashes.PlayerSnapData, "extra_player_setup")
	register_spawner(RocketLauncherSnapData,Resources.gameplayscenes.RocketLauncher,Resources.chashes.RocketLauncherSnapData,"extra_item_setup")
	register_spawner(RocketSnapData,Resources.gameplayscenes.Rocket,Resources.chashes.RocketSnapData,"extra_object_setup")
	register_spawner(RocketExplosionSnapData,Resources.gameplayscenes.RocketExplosion,Resources.chashes.RocketExplosionSnapData,"extra_object_setup")

func register_spawner(script: Script, gameplay_scene_id: int, chash_id: int, extra_setup: String) -> void:
	var scene: PackedScene = Resources.get_gameplay_scene(gameplay_scene_id)
	var chash: int = Resources.get_chash(chash_id)
	Network.snapshot_data.register_spawner(script, chash, NetDefaultSpawner.new(scene), map, funcref(self,extra_setup))

static func extra_player_setup(ret) -> void:
	pass

static func extra_item_setup(ret) -> void:
	pass

static func extra_object_setup(ret) -> void:
	pass

# ////////////////////////////////////


# CONNECTION STUFF
# ////////////////////////////////////
func reset() -> void:
	print("Resetting network.")
	# according to  docs close server does nothing on clients and disconnect
	# from server does nothing if youre a server, so we should be gucci
	Network.close_server()
	Network.disconnect_from_server()
	set_physics_process(false)
	go_to_main_menu_if_map_is_current_scene()
#	Network.reset_input()
	Network.reset_system()
	local_player = null
	Quack.change_scene("res://Interface/Menus/Main Menu.tscn")

func reset_if_connected() -> void:
	print_debug("getting a network peer doesnt work the second time")
	if Quack.tree.has_network_peer():
		if is_server():
			shutdown_server()
		else:
			disconnect_from_server()

func disconnect_from_server() -> void:
	print("Disconnecting from server.")
	reset()

func shutdown_server() -> void:
	print("Shutting down server.")
	reset()

func go_to_main_menu_if_map_is_current_scene() -> void:
	if Quack.tree.current_scene is Map:
		Quack.change_scene(Resources.get_menu_name(Resources.menu_names.MainMenu))

func on_player_added(id: int) -> void:
	print("Client %s added."%[id])
	player_ids.append(id)
	prints("DEBUG",player_ids,Quack.tree.get_network_connected_peers())
	rpc_id(id,"client_start",map_path)
	print_debug("get rid of this after")
	if is_server():
		try_respawning_player(id)

func on_player_removed(id: int) -> void:
	print("Client %s removed."%[id])
	# might get super expensive with larger player numbers... look into this
	player_ids.remove(id)

func on_connection_succeeded() -> void:
	print("Connection succeeded!")

func on_connection_failed() -> void:
	print("Connection failed.")

func on_join_rejected(reason: String) -> void:
	pass

func on_kicked(reason: String) -> void:
	pass

func connect_to_server(server_ip: String = localhost, server_port: int = DEFAULT_PORT) -> void:
	reset_if_connected()
	print("Attempting to connect to %s on port %s."%[server_ip, server_port])
	Network.join_server(server_ip,server_port)
# ////////////////////////////////////


# AUTHORITY STATUS STUFF
# ////////////////////////////////////
static func is_client() -> bool:
	return !Network.has_authority()

static func is_server() -> bool:
	return Network.has_authority()
# ////////////////////////////////////


# LOBBY STATUS STUFF
# ////////////////////////////////////
# might get super expensive with larger player numbers... look into this
const player_ids = PoolIntArray([])
static func get_player_nodes() -> Array:
	return Network.get_children()
static func get_player_ids() -> PoolIntArray:
# warning-ignore:unassigned_variable
	var array: PoolIntArray
	for player in get_player_nodes():
		array.append((player as NetPlayerNode).get_uid())
	return array
# ////////////////////////////////////


# SETUP STUFF
# ////////////////////////////////////
static func tickrate_if_0(i: int) -> int:
	return Quack.get_tickrate() if i <= 0 else i
func create_server(map_filepath: String, _max_players: int = 10, _max_spectators: int = 2, _gamemode: Array = [],
				tickrate: int = 60, server_port: int = DEFAULT_PORT) -> void:
	reset_if_connected()
	tickrate = tickrate_if_0(tickrate)
	max_players = _max_players
	max_spectators = _max_spectators
#	if this_gamemode == []:
#		gamemode.append_array(Gamemodes.make_default_gamemode())
#	else:
#		gamemode.append_array(this_gamemode)
#	game_timer.target_time = Gamemodes.get_game_time_limit(gamemode)
#	round_timer.target_time = Gamemodes.get_round_time_limit(gamemode)
	print("Server Created on port %s with a player limit of %s and spectator limit of %s."%
	[server_port, max_players, max_spectators])
#	setup_server_connections()
#	setup_server_tick_funcs()
	Quack.append_to_window_title(" (SERVER)")
	setup_map(map_filepath)
	Network.create_server(server_port,"Quack Server",max_players + max_spectators)
	call_deferred("start")
# ////////////////////////////////////


# SIMULATION STUFF
# ////////////////////////////////////
var tick_func: FuncRef
var physics_tick_func: FuncRef
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	Network.init_snapshot()
	if is_server():
		physics_tick_server(delta)
	else:
		physics_tick_client(delta)

#func spawn_node(node: Spatial, transform: Transform) -> void:
#	node.global_transform = transform

# CLIENT
# /////////////
func tick_client(delta: float) -> void:
	pass
func physics_tick_client(delta: float) -> void:
	pass

# SERVER
# /////////////
const respawn_queue = {}
func poll_for_respawns(delta: float) -> void:
	for id in respawn_queue.keys():
		respawn_queue[id] -= delta
		if respawn_queue[id] <= 0.0:
			if try_respawning_player(id):
				respawn_queue.erase(id)
func try_respawning_player(id: int) -> void:
	printerr("temp spawning logic")
	var player_node: NetPlayerNode = Network.player_data.get_pnode(id)
	var player_character: PlayerCharacter = Network.snapshot_data.spawn_node(PlayerSnapData,id,Resources.get_chash(Resources.chashes.PlayerSnapData))
	player_character.global_transform.origin = Vector3(0,40,0)
	var rocketlauncher: SingleLoader = Network.snapshot_data.spawn_node(RocketLauncherSnapData,id+1,Resources.get_chash(Resources.chashes.RocketLauncherSnapData))
	map.reparent_node(rocketlauncher,player_character)
#	if is_respawning_allowed():
#		match Gamemodes.get_team_type(gamemode):
#			Gamemodes.team_type.FFA:
#				server_spawn_player(id,{PlayerCharacter.OWNER_ID: id})
#			Gamemodes.team_type.COOP:
#				pass
#			Gamemodes.team_type.TWOTEAMS:
#				pass
#			Gamemodes.team_type.THREETEAMS:
#				pass
#			_:
#				server_spawn_player(id,{})
#		return true
#	else:
#		return false
enum {GET_GAMEMODE_RESPAWN_TIME = -1}
func add_player_to_respawn_queue(id: int, with_time: int = GET_GAMEMODE_RESPAWN_TIME) -> void:
	if GET_GAMEMODE_RESPAWN_TIME:
		printerr("temp value")
		with_time = 0# get gamemode time
	if !respawn_queue.keys().has(id):
		print("Queuing player id %s for respawn"%[id])
		respawn_queue[id] = with_time
	else:
		printerr("Player %s already queued for respawn!"%[id])

func physics_tick_server(delta: float) -> void:
	poll_for_respawns(delta)
#		Network.snapshot_data.get_game_node(Network.player_data.get_pnode(id).net_id,PlayerSnapData)

# HOST
# /////////////
func physics_tick_host(delta: float) -> void:
	pass
# ////////////////////////////////////
