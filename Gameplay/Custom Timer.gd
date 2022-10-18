extends Reference
class_name CustomTimer

var max_time: float
var time_left: float
var is_running: bool
var repeats: bool
signal finished(remainder,interp_fraction)

const ONEFRAME = 0.0

func _init(maxtime: float,should_repeat: bool) -> void:
	assert(maxtime >= ONEFRAME)
	max_time = maxtime
	time_left = max_time
	repeats = should_repeat

func tick(delta: float) -> void:
	emit_finished(ONEFRAME) if max_time == ONEFRAME else tick_normal(delta)

func tick_normal(delta: float) -> void:
	time_left -= delta
	if time_left <= 0.0:
		var remainder: float
		remainder = abs(time_left)
		if repeats:
			if remainder:
				reset_time()
				emit_finished(remainder)
				tick(abs(time_left))
		else:
			stop()
			emit_finished(remainder)

func emit_finished(remainder: float) -> void:
	emit_signal("finished",remainder,Quack.interpfrac)

func start() -> void:
	is_running = true

func pause() -> void:
	is_running = false

func stop() -> void:
	is_running = false
	reset_time()

func reset_time() -> void:
	time_left = max_time
