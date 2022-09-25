extends CanvasLayer

export var show_fps: bool
export var show_interp_fraction: bool
export var show_delta: bool
export var show_physics_delta: bool
export var show_quack_delta: bool
export var show_process_time: bool
export var show_physics_process_time: bool
export var show_process_delta_time_diff: bool
export var show_process_quack_delta_diff: bool
export var show_physics_process_delta_time_diff: bool
export var show_ping: bool
export var show_rtt: bool
export var show_ticks_behind: bool
export var show_input_cache_size: bool
export var show_packet_loss: bool
export var show_tickrate: bool
#export var show_

onready var fps_readout: Label = $HFlowContainer/fpscontainer/readout
onready var interp_fraction_readout: Label = $HFlowContainer/interpcontainer/readout
onready var delta_readout: Label = $HFlowContainer/deltacontainer/readout
onready var physics_delta_readout: Label = $HFlowContainer/physdeltacontainer/readout
onready var quack_delta_readout: Label = $HFlowContainer/quackdeltacontainer/readout
onready var process_time_readout: Label = $HFlowContainer/processcontainer/readout
onready var physics_process_time_readout: Label = $HFlowContainer/physprocesscontainer/readout
onready var process_delta_time_diff_readout: Label = $HFlowContainer/processdeltadiffcontainer/readout
onready var process_quack_delta_diff_readout: Label = $HFlowContainer/processquackdiffcontainer/readout
onready var physics_process_delta_time_diff_readout: Label = $HFlowContainer/physprocessdeltadiffcontainer/readout
onready var input_cache_size_readout: Label = $HFlowContainer/inputcachesizecontainer/readout
onready var tickrate_readout: Label = $HFlowContainer/tickratecontainer/readout
onready var ping_readout: Label = $HFlowContainer/pingcontainer/readout

func _ready() -> void:
	var hflowcontainer: HFlowContainer = get_child(0)
	for child in hflowcontainer.get_children():
		child.set_visible(false)
	fps_readout.get_parent().set_visible(show_fps)
	interp_fraction_readout.get_parent().set_visible(show_interp_fraction)
	delta_readout.get_parent().set_visible(show_delta)
	physics_delta_readout.get_parent().set_visible(show_physics_delta)
	quack_delta_readout.get_parent().set_visible(show_quack_delta)
	process_time_readout.get_parent().set_visible(show_process_time)
	physics_process_time_readout.get_parent().set_visible(show_physics_process_time)
	process_delta_time_diff_readout.get_parent().set_visible(show_process_delta_time_diff)
	process_quack_delta_diff_readout.get_parent().set_visible(show_process_quack_delta_diff)
	physics_process_delta_time_diff_readout.get_parent().set_visible(show_physics_process_delta_time_diff)
	input_cache_size_readout.get_parent().set_visible(show_input_cache_size)
	tickrate_readout.get_parent().set_visible(show_tickrate)
	ping_readout.get_parent().set_visible(show_ping)
	# if ur tryna make it so ppl can turn labels back on then this shouldnt be a thing
	for child in hflowcontainer.get_children():
		if child.visible == false:
			child.queue_free()
	if show_ping:
		Network.connect("localping",self,"set_ping")

func set_ping(ping: int) -> void:
	ping_readout.set_text(str(ping))

var processtime: float
var physprocesstime: float
func _process(delta: float) -> void:
	if show_fps:
		fps_readout.set_text(str(Engine.get_frames_per_second()))
	if show_interp_fraction:
		interp_fraction_readout.set_text(str(Quack.interpfrac))
	if show_delta:
		delta_readout.set_text(str(delta))
	processtime = Performance.get_monitor(Performance.TIME_PROCESS)
	if show_process_time:
		process_time_readout.set_text(str(processtime))
	if show_quack_delta:
		quack_delta_readout.set_text(str(Quack.delta_time))
	if show_process_delta_time_diff:
		process_delta_time_diff_readout.set_text(str(delta - processtime))
	if show_process_quack_delta_diff:
		process_quack_delta_diff_readout.set_text(str(delta - Quack.delta_time))

func _physics_process(delta: float) -> void:
	physprocesstime = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	if show_physics_delta:
		physics_delta_readout.set_text(str(delta))
	if show_physics_process_time:
		physics_process_time_readout.set_text(str(physprocesstime))
	if show_physics_process_delta_time_diff:
		physics_process_delta_time_diff_readout.set_text(str(delta - physprocesstime))
	if show_tickrate:
		tickrate_readout.set_text(str(Quack.get_tickrate()))
	if show_input_cache_size:
		input_cache_size_readout.set_text(str(Inputs.get_local_cached_inputs().size()))
