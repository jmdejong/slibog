extends Node

const config_path: String = "user://config.cfg"

enum Perf {FAST = 1, PRETTY = 9}

var config_file = ConfigFile.new()
var performance: Perf = Perf.FAST 
signal performance_changed
var cheats_enabled: bool = false
signal debug_info_enabled_changed(enabled: bool)
var debug_info_enabled: bool = true

const saved_properties: Array[StringName] = ["performance", "cheats_enabled", "debug_info_enabled"]

func configure_defaults() -> void:
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		performance = Perf.FAST
	else:
		performance = Perf.PRETTY

func configure_from_file() -> void:
	for property: StringName in saved_properties:
		set(property, config_file.get_value("general", property, get(property)))

func _ready() -> void:
	Measure.start("load_config")
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
	Measure.finish("load_config")

func set_performance(perf: Perf) -> void:
	var old_perf: Perf = performance
	performance = perf
	save()
	if perf != old_perf:
		performance_changed.emit()

func set_cheats(enabled: bool) -> void:
	cheats_enabled = enabled
	save()

func set_debug_info(enabled: bool) -> void:
	debug_info_enabled = enabled
	save()
	debug_info_enabled_changed.emit(enabled)

func save() -> void:
	for property: StringName in saved_properties:
		config_file.set_value("general", property, get(property))
	config_file.save(config_path)
