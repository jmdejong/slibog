extends Node


var measurements: Dictionary[String, int] = {}

func start(name: String) -> void:
	measurements[name] = now()
	prints("%5.3f" % measurements[name], "starting", name)

func finish(name: String) -> void:
	var n: float = now()
	if not measurements.has(name):
		prints("%5.3f" % n, "finishing", name, "without starting")
	prints("%5.3f" % n, name, "took", "%5.3f" % (n - measurements[name]))

func now() -> float:
	return float(Time.get_ticks_msec()) / 1000
