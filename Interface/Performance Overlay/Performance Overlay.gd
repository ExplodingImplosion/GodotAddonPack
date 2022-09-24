extends Control

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
export var show_prediction_count: bool
export var show_packet_loss: bool
export var show_tickrate: bool
#export var show_

#onready var fps_readout: Label = 
#onready var interp_fraction_readout: Label = 
#onready var delta_readout: Label = 
#onready var physics_delta_readout: Label = 
#onready var quack_delta_readout: Label = 
#onready var process_time_readout: Label = 
#onready var physics_process_time_readout: Label = 
#onready var process_delta_time_diff_readout: Label = 
#onready var process_quack_delta_diff_readout: Label = 
#onready var physics_process_delta_time_diff_readout: Label = 

func _process(delta: float) -> void:
	pass

func _physic_process(delta: float) -> void:
	pass
