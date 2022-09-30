extends WindowDialog

const postfix := "_cmd"
const toggle := "console"
const up := "ui_up"
const down := "ui_down"
const UP := -1
const DOWN := 1
const MINSIZE := Vector2(200,100)
const DEFAULTSIZE := Vector2(600,650)
const DEFAULTPOS := Vector2(40,40)
const convert_args := true
var label := RichTextLabel.new()
var line := LineEdit.new()
var c := VBoxContainer.new()

var current := 0
const history := []
const commands := {}
var cmd_args_amount := {}
const bbcode_colors = {
	line = Color(0.8,0.8,0.8,1),
	error = Color(1,0.2,0.2,1),
	warning = Color(1,1,0.2,1)
}
class ConsoleBBCodeColor extends RichTextEffect:
	var bbcode: String = "bbcode"
	var colors
	func _init(_colors):
		colors = _colors
	func _process_custom_fx(fx):
		var c = colors.get(fx.env.get("c"))
		if c is Color:
			fx.color = c
		return true

func _init() -> void:
	connect_node(self)
	setup_window()
	add_child(c)
	setup_margins(c)
	setup_label()
	setup_line()
	hide()

#func _ready() -> void:
#	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(toggle):
		toggle_activation()
	if Input.is_action_just_pressed(up):
		if can_history_move():
			move_in_history(UP)
	if Input.is_action_just_pressed(down):
		if can_history_move():
			move_in_history(DOWN)

func _physics_process(delta: float) -> void:
	pass

func setup_window() -> void:
	set_title("Console")
	# depreciated?
	setup_window_properties()
	set_custom_minimum_size(MINSIZE)
	set_position(DEFAULTPOS)
#	call_deferred("setup_window_size")

func setup_window_size() -> void:
	Quack.setup_subwindow_size(self,DEFAULTSIZE)

func setup_window_properties() -> void:
	pass
	# depreciated?
#	popup_exclusive = true
	# redundant
#	set_flag(window.flag.Window.FLAG_RESIZE_DISABLED, false)

func setup_c() -> void:
	add_child(c)
	setup_margins(c)

static func setup_margins(container: VBoxContainer) -> void:
#	return
	# this shit is broken lol
#	container.margin_bottom = 0
#	container.margin_left = 0
#	container.margin_top = 0
#	container.margin_right = 0
	container.anchor_bottom = 1
	container.anchor_left = 0
	container.anchor_top = 0
	container.anchor_right = 1

func setup_label() -> void:
	setup_label_properties(label)
	c.add_child(label)
	label.set_focus_mode(Control.FOCUS_NONE)

static func setup_label_properties(this_label: RichTextLabel) -> void:
	this_label.set_use_bbcode(true)
	this_label.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	this_label.set_scroll_follow(true)
	this_label.set_selection_enabled(true)
	this_label.install_effect(ConsoleBBCodeColor.new(bbcode_colors))

func setup_line() -> void:
	setup_line_properties(line, self)
	c.add_child(line)

static func setup_line_properties(this_line: LineEdit, console: WindowDialog) -> void:
	this_line.connect("text_entered", console, "command")
	this_line.set_clear_button_enabled(true)

func toggle_activation() -> void:
	disable() if is_visible() else activate()

func activate() -> void:
	popup()
	line.grab_focus()
	Inputs.show_cursor()
#	if position.x > Quack.root.size.x or position.y > Quack.root.size.y:
	setup_window_size()
	# functionally the same as:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func disable() -> void:
	hide()
	line.clear()
	# this might get depreciated if the console/menu disconnects the mouse
	# from getting captured
	if Inputs.is_mouse_connected_to_object():
		Inputs.capture_cursor()

func reconnect_nodes() -> void:
	pass

func move_in_history(amount: int) -> void:
	current = int(clamp(current + amount, 0, history.size() - 1))
	line.set_text(history[current])
	line.caret_position = line.get_text().length()

func is_line_focused() -> bool:
	return true if get_focus_owner() == line else false

func can_history_move() -> bool:
	return true if is_line_focused() and !history.empty() else false

func connect_node(node: Node, in_list: bool = false) -> void:
	for method in node.get_method_list():
		var method_name: String = method.name
		if method_name.ends_with(postfix):
			method_name = method_name.trim_suffix(postfix)
			commands[method_name] = node;
			cmd_args_amount[method_name] = method.args.size()

func write(s: String, bbcode = null) -> void:
	label.append_bbcode(bbcode_wrap(s, bbcode_wrap(s, bbcode)))
	print(s)

func bbcode_wrap(s: String, bbcode = null) -> String:
	return str(s) if bbcode == null else str("[bbcode c=", bbcode, "]", s, "[/bbcode]")

func command(cmd: String):
	if cmd == "":
		return
	line.clear()
	write(str("\n" if label.text.length() != 0 else "", "> ", cmd), "line")
	var args: Array = Array(cmd.split(" "))
	var command: String = args.pop_front()
	if convert_args:
		for i in args.size():
			if args[i] == "false":
				args[i] = false
			elif args[i] == "true":
				args[i] = true
			elif args[i].is_valid_float():
				args[i] = args[i].to_float()
			elif args[i].is_valid_integer():
				args[i] = args[i].to_int()
			elif "_" in args[i]:
				args[i] = str(args[i]).replace("_", " ")
	var node = commands.get(command)
	if node:
		args.resize(cmd_args_amount[command])
		node.callv(command + postfix, args)
	else:
		command_not_found(command)
	history.append(cmd)
	current = history.size()

func command_not_found(command: String) -> void:
	write(str("Command '", command, "' not found"), "error")



#///////////////////////////////////////////////////////////////////////////////
# CONSOLE COMMANDS
#///////////////////////////////////////////////////////////////////////////////


func quit_cmd() -> void:
	Quack.quit()

func host_cmd(file: String) -> void:
	qNetwork.create_server(Map.map_path_from_name(file))

func connect_cmd(ip: String) -> void:
	qNetwork.connect_to_server(ip)

const perf_menu: PackedScene = preload("res://Interface/Performance Overlay/Performance Overlay.tscn")
var perf_overlay: CanvasLayer
func performance_overlay_cmd() -> void:
	if perf_overlay == null:
		perf_overlay = perf_menu.instance()
		Quack.root.add_child(perf_overlay)
	else:
		perf_overlay.queue_free()
		perf_overlay = null
func perf_overlay_cmd() -> void:
	performance_overlay_cmd()

const playerinfomenu: PackedScene = preload("res://Interface/Player Info Display/Player Info Display.tscn")
var playerinfodisplay: CanvasLayer
func player_info_display_cmd(idx: int) -> void:
	if playerinfodisplay == null:
		playerinfodisplay = playerinfomenu.instance()
		playerinfodisplay.playeridx = idx
		Quack.root.add_child(playerinfodisplay)
	else:
		playerinfodisplay.queue_free()
		playerinfodisplay = null
func playerinfo_cmd(idx: int) -> void:
	player_info_display_cmd(idx)
func display_player_info_cmd(idx: int) -> void:
	player_info_display_cmd(idx)
func showplayerinfo_cmd(idx: int) -> void:
	player_info_display_cmd(idx)

func max_fps_cmd(fps: int) -> void:
	Engine.set_target_fps(fps)

func disconnect_cmd() -> void:
	qNetwork.disconnect_from_server()

func shutdown_cmd() -> void:
	qNetwork.shutdown_server()
