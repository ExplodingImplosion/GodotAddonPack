extends Node

const DEBUG_WINDOW_SIZE := Vector2(768, 450)
const DEBUG_WINDOW_POS := Vector2(20,40)

var current_time: float = 0
var last_time: float = 0
var delta_time: float = 0
var interpfrac: float = 0

var current_time_thread: float = 0
#var last_time_thread: float = 0
var delta_time_thread: float = 0
var time_thread := Thread.new()

onready var tree: SceneTree = get_tree()
onready var root: Viewport = tree.get_root()

func is_startup() -> bool:
	return current_time == 0
func do_time_thread(n = null) -> void:
	for i in INF:
		current_time_thread = OS.get_ticks_usec() * 0.000001
		delta_time_thread = current_time_thread - last_time#_thread
#		print(delta_time_thread)
#		last_time_thread = current_time_thread
#		if current_time_thread != current_time:
#			print("thread: threaded time %s != %s"%[current_time_thread, current_time])
func _process(delta: float) -> void:
	current_time = OS.get_ticks_usec() * 0.000001
	delta_time = current_time - last_time
	last_time = current_time
	interpfrac = get_interpfrac()
#	if current_time_thread != current_time:
#		print("main: threaded time %s != %s"%[current_time_thread, current_time])
static func printusec() -> void:
	print(OS.get_ticks_usec())

func tick_time_value_towards(value: float, towards: float) -> float:
	value += delta_time
	return towards - value

func tick_time_value_down(value: float) -> float:
	return value - delta_time

func tick_time_value_up(value: float) -> float:
	return value + delta_time


func _init() -> void:
	Resources.build_chashes()
func _ready() -> void:
	setup_connections()
	setup_filepaths()
	on_window_resized()
	return
# warning-ignore:unreachable_code
	if time_thread.start(self,"do_time_thread") != OK:
		printerr("fuck off, do_time_thread != OK")
		quit()
	# for some reason this crashes???
#	add_meta_recursive(get_tree().current_scene,"is_networked",false)

static func add_meta(node: Node,meta: String,value) -> void:
	node.set_meta(meta,value)

static func add_meta_recursive(node: Node,meta: String,value) -> void:
	for child in node.get_children():
		add_meta(child,meta,value)
		add_meta_recursive(child,meta,value)

func setup_filepaths() -> void:
	var dir := Directory.new()
	if !dir.dir_exists("user://replays"):
		# maybe make_dir_recursive?
# warning-ignore:return_value_discarded
		dir.make_dir("user://replays")
func setup_connections() -> void:
# warning-ignore:return_value_discarded
	root.connect("size_changed",self,"on_window_resized")

enum {DEFAULT_WINDOW_SIZE_x = 1920,DEFAULT_WINDOW_SIZE_y = 1080}
func on_window_resized() -> void:
	for child in root.get_children():
		if child is Control:
			child.set_scale(Vector2(root.size.x/float(DEFAULT_WINDOW_SIZE_x),
									root.size.y/float(DEFAULT_WINDOW_SIZE_y)))

func get_root_last_child() -> Node:
	return root.get_child(root.get_child_count() - 1)

func get_root() -> Viewport:
	return get_tree().get_root()

func refresh_root() -> void:
	root = get_root()

func refresh_tree() -> void:
	tree = get_tree()
#	refresh_root()

func get_entities(group: String) -> Array:
	return tree.get_nodes_in_group(group)

func get_current_camera() -> Camera:
	return root.get_camera_3d()

func go_fullscreen() -> void:
	OS.set_window_fullscreen(true)

func go_windowed() -> void:
	OS.set_window_fullscreen(false)

static func is_windowed() -> bool:
	return !OS.window_fullscreen

func set_fullscreen(enabled: bool = true) -> void:
# warning-ignore:standalone_ternary
	go_fullscreen() if enabled else go_windowed()
# functionally the same as:
#	if enabled:
#		get_tree().get_root().set_mode(Window.MODE_FULLSCREEN)
#	else:
#		get_tree().get_root().set_mode(Window.MODE_WINDOWED)

func set_borderless(enabled: bool = false) -> void:
	OS.set_borderless_window(enabled)

func go_debug_window() -> void:
	if !is_windowed():
		go_windowed()
	OS.set_window_size(DEBUG_WINDOW_SIZE)
	OS.set_window_position(DEBUG_WINDOW_POS)

func change_scene(scene: String) -> void:
# warning-ignore:return_value_discarded
	tree.change_scene(scene)
	call_deferred("on_window_resized")

func quit() -> void:
	tree.quit()

static func show_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

static func capture_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

static func is_mouse_captured() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

static func showhide_cursor_on_ui_cancel() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		showhide_cursor()

static func showhide_cursor() -> void:
# warning-ignore:standalone_ternary
	capture_cursor() if is_mouse_visible() else show_cursor()

static func is_mouse_visible() -> bool:
#	return true if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE else false
	match Input.get_mouse_mode():
		Input.MOUSE_MODE_VISIBLE:
			return true
		Input.MOUSE_MODE_CONFINED:
			return true
		_:
			return false

static func get_interpfrac() -> float:
	return Engine.get_physics_interpolation_fraction()

static func datetime_string() -> String:
	return OS.get_datetime_string_from_system(false, true).replace(":", "-")

static func get_tickrate() -> int:
	return Engine.get_physics_ticks_per_second()

static func set_tickrate(rate: int) -> void:
	Engine.set_physics_ticks_per_second(rate)

static func set_max_fps(fps: int) -> void:
	Engine.set_target_fps(fps)

static func array_getlast(array: Array):
	return array[array.size() - 1]

static func array_getlastidx(array: Array) -> int:
	return array.size() - 1

static func global_orientation(obj: Spatial) -> Vector3:
	# tbh normailizing this changes like basically nothing so maybe its not worth doing
	# example: changes (-0.318499, -0.088899, 0.943740) into (-0.318501, -0.088899, 0.943745)
	return obj.global_transform.basis.z.normalized()

static func get_window_title() -> String:
	return "Quack (DEBUG)" if OS.is_debug_build() else "Quack"

static func is_exported() -> bool:
	return OS.has_feature("standalone")

func change_window_title(title: String) -> void:
	OS.set_window_title(title)

func reset_window_title() -> void:
	change_window_title(get_window_title())

func append_to_window_title(title: String) -> void:
	change_window_title(get_window_title() + title)

static func is_timer_running(timer: Timer) -> bool:
	# if a timer is inactive it also returns 0, so this works no matter what :)
	return false if timer.get_time_left() == 0.0 else true

static func is_freed_instance(obj: Object) -> bool:
	return weakref(obj).get_ref() == null

static func get_dict_from_array(array: Array) -> Dictionary:
# warning-ignore:unassigned_variable
	var dict: Dictionary
	for idx in array.size():
		dict[idx] = array[idx]
	return dict

static func apply_array_to_dict(dict: Dictionary, array: Array) -> void:
	for idx in array.size():
		dict[idx] = array[idx]

static func types_are_same(var1, var2) -> bool:
	return typeof(var1) == typeof(var2)

func setup_subwindow_size(subwindow: Popup, size: Vector2) -> void:
	if root.size.x < size.x:
		size.x = Quack.root.size.x - 60
	if root.size.y < size.y:
		size.y = Quack.root.size.y - 60
	subwindow.set_size(size)
	if subwindow.position.x > root.size.x or subwindow.position.x < root.position.x:
		subwindow.position.x = root.size.x - subwindow.size.x - 20
	if subwindow.position.y > root.size.y or subwindow.position.y < root.position.y:
		subwindow.position.y = root.size.y - subwindow.size.y - 20

static func is_multiple_of(a: int, b: int) -> bool:
# warning-ignore:integer_division
	return true if (float(a) / b) == a/b else false

static func print_meta_list_for_node_and_children(node: Node) -> void:
	for child in node.get_children():
		print("--------------")
		print(child.get_name())
		print("--------------")
		print(child.get_meta_list())
		print("-------------------------------")
		print_meta_list_for_node_and_children(child)
		print("-------------------------------")

static func get_func_length(function: FuncRef) -> int:
	var time2: int
	var time: int = OS.get_ticks_usec()
	function.call_func()
	time2 = OS.get_ticks_usec()
	return time2 - time
