extends Node

const config_path: String = "user://config.ini"

enum Perf {FAST = 1, PRETTY = 9}

var config_file = ConfigFile.new()
var performance: Perf = Perf.FAST 
signal performance_changed()

func configure_defaults() -> void:
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		performance = Perf.FAST
	else:
		performance = Perf.PRETTY

func configure_from_file() -> void:
	performance = config_file.get_value("general", "performance", performance)

func _ready() -> void:
	configure_defaults()
	var err: Error = config_file.load(config_path)
	if err == Error.ERR_FILE_NOT_FOUND:
		print("no config file found; using platform defaults")
		save()
		return
	elif err != Error.OK:
		printerr("Unable to load config file: ", error_string(err), "; using platform defaults")
		return
	else:
		print("config loaded sucessfully")
		configure_from_file()

func set_performance(perf: Perf):
	var old_perf: Perf = performance
	performance = perf
	save()
	if perf != old_perf:
		performance_changed.emit()

func save() -> void:
	config_file.set_value("general", "performance", performance)
	config_file.save(config_path)
