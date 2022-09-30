extends CanvasLayer

export var showposition: bool
export var showvelocity: bool
export var showinputdir: bool
export var showinputs: bool
export var showaimangle: bool
export var showhealth: bool
export var showteam: bool
export var showcrouchamnt: bool
export var showhascorrection: bool
export var showdirection: bool
export var showtempvel: bool
export var showtarget: bool
export var showtempaccel: bool
export var showonfloor: bool
export var showdirectiondotvel: bool
export var showboundingbox: bool

onready var positionreadout: Label =$HFlowContainer/positioncontainer/readout
onready var velocityreadout: Label =$HFlowContainer/velocitycontainer/readout
onready var inputdirreadout: Label =$HFlowContainer/inputdircontainer/readout
onready var inputsreadout: Label =$HFlowContainer/inputscontainer/readout
onready var aimanglereadout: Label =$HFlowContainer/aimanglecontainer/readout
onready var healthreadout: Label =$HFlowContainer/healthcontainer/readout
onready var teamreadout: Label =$HFlowContainer/teamcontainer/readout
onready var crouchamntreadout: Label =$HFlowContainer/crouchamountcontainer/readout
onready var hascorrectionreadout: Label =$HFlowContainer/hascorrectioncontainer/readout
onready var directionreadout: Label =$HFlowContainer/directioncontainer/readout
onready var tempvelreadout: Label =$HFlowContainer/tempvelcontainer/readout
onready var targetreadout: Label =$HFlowContainer/targetcontainer/readout
onready var tempaccelreadout: Label =$HFlowContainer/tempaccelcontainer/readout
onready var onfloorreadout: Label =$HFlowContainer/onfloorcontainer/readout
onready var directiondotvelreadout: Label =$HFlowContainer/directiondotvelcontainer/readout
onready var boundingboxreadout: Label = $HFlowContainer/boundingboxcontainer/readout

var myplayer: PlayerCharacter

func _ready() -> void:
	var hflow: HFlowContainer = get_child(0)
	for child in hflow.get_children():
		child.set_visible(false)
	var showarray: PoolStringArray
	var readoutarray: PoolStringArray
	for property in get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var propname: String = property.name
			if propname.begins_with("show"):
				showarray.append(propname)
			elif propname.ends_with("readout"):
				readoutarray.append(propname)
	for idx in showarray.size():
		self[readoutarray[idx]].get_parent().set_visible(self[showarray[idx]])
	for child in hflow.get_children():
		if child.visible == false:
			child.queue_free()

func _physics_process(delta: float) -> void:
	var map: Map = qNetwork.map
	if Quack.return_null_if_freed_or_will_be(map) != null:
		myplayer = Quack.return_null_if_freed_or_will_be(myplayer)
		if myplayer != null:
			if showposition:
				positionreadout.set_text(str(myplayer.global_transform.origin))
			if showvelocity:
				velocityreadout.set_text(str(myplayer.velocity))
			if showinputdir:
				inputdirreadout.set_text(str(myplayer.input_dir))
			if showinputs:
				inputsreadout.set_text(str(myplayer.inputs))
			if showaimangle:
				aimanglereadout.set_text(str(myplayer.aim_angle))
			if showhealth:
				healthreadout.set_text(str(myplayer.health))
			if showteam:
				teamreadout.set_text(str(myplayer.team))
			if showcrouchamnt:
				crouchamntreadout.set_text(str(myplayer.crouch_amount))
			if showhascorrection:
				hascorrectionreadout.set_text(str(myplayer.has_correction))
			if showdirection:
				directionreadout.set_text(str(myplayer.direction))
			if showtempvel:
				tempvelreadout.set_text(str(myplayer.temp_vel))
			if showtarget:
				targetreadout.set_text(str(myplayer.target))
			if showtempaccel:
				tempaccelreadout.set_text(str(myplayer.temp_accel))
			if showonfloor:
				onfloorreadout.set_text(str(myplayer.is_on_floor()))
			if showdirection:
				directiondotvelreadout.set_text(str(myplayer.direction.dot(myplayer.velocity)))
			if showboundingbox:
				boundingboxreadout.set_text(str(myplayer.boundingbox.area.scale))
		else:
			var kids: Array = map.get_children()
			for idx in kids.size():
				var child: Node = kids[idx]
				var pidx: int
				if child is PlayerCharacter:
					if playeridx == pidx:
						myplayer = child
					else:
						pidx += 1

var playeridx: int = -1
