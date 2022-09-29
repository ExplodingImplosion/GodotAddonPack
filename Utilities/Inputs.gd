extends Node

signal mouse_moved(relative)
signal pause_pressed

func is_mouse_connected_to_object() -> bool:
	return false if get_signal_connection_list("mouse_moved").empty() else true

static func capture_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

static func show_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

onready var sens: float = getsens() * 0.01

func getsens() -> float:
	print_debug("getsens isnt working rn, no setting change")
	return 5.0

func update_sens() -> void:
	sens = getsens() * 0.01

func change_sensitivity(newsens: float) -> void:
	print_debug("change_sens isnt working, no setting change")
	sens = newsens * 0.01

func _input(event):
	if event is InputEventMouseMotion:
		emit_signal("mouse_moved", event.relative * sens)
	elif Input.is_action_just_pressed("ui_cancel"):
		emit_signal("pause_pressed")

# this is so dumb lmfao
static func mouse_to_aim(event: InputEventMouseMotion) -> Vector2:
	return event.relative

const action_events: PoolStringArray = PoolStringArray([])
const action_event_indexes: Dictionary = {}

enum {UP}

static func bit_has_flag(bit: int, flag: int) -> bool:
	return bool(bit&flag)

static func action_pressed_as_bitflag(action: String, this_int: int) -> int:
	return this_int if Input.is_action_pressed(action) else UP

static func action_just_pressed_as_bitflag(action: String, this_int: int) -> int:
	return this_int if Input.is_action_just_pressed(action) else UP

#static func get_keyboard_updowns() -> int:
#	var updowns: int
#	for action in pressed:
#		updowns |= action_pressed_as_bitflag(action_events[action], action_bitfields[action])
#	var thisaction: int
#	for action in diff:
#		thisaction = action + pressed
#		updowns |= action_just_pressed_as_bitflag(action_events[thisaction], action_bitfields[thisaction])
#	return updowns

# INPUT REGISTRATION STUFF
# ////////////////////////////////////
static func is_ui_action(action: String) -> bool:
	return action.begins_with("ui_")

static func is_analog_action(action: String) -> bool:
	return action.begins_with("analog_")

static func register_all_actions() -> void:
	for action in InputMap.get_actions():
		if !is_ui_action(action) and !is_analog_action(action):
			Network.register_action(action,false)

static func register_custom_input_stuff() -> void:
	Network.register_custom_input_vec2("input_dir")
	Network.register_custom_input_vec2("aim_angle")

static func register_action(action: String) -> void:
	action_events.append(action)
	action_event_indexes[action] = action_events.size()-1
# ////////////////////////////////////

# if i catch anyone using these 2 funcs im going to personally shoot them
static func get_bool_from_action_pressed(action: String) -> bool:
	return Input.is_action_pressed(action)

static func get_bool_from_action_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed(action)

static func get_movement_from_keyboard() -> Vector2:
	return Input.get_vector("analog_left","analog_right","analog_forward","analog_back")

static func get_local_cached_inputs() -> Array:
	return Network.player_data.local_player.get_cached_input_list()

static func get_player_cached_inputs(player: int) -> Array:
	return Network.player_data.remote_player[player].get_cached_input_list()
# depreciated. use bit_has_flag
#static func is_updown_pressed(updown: int) -> bool:
#	return true if updown == DOWN else false

# lmk if this function has ever been used ever in the history of ever period
enum {UPDOWNS, ANGLE}
static func make_input_struct(updowns: int, angle: Vector2) -> Array:
	return [updowns, angle]
