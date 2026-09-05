extends Node


#var achievements: Array[StringName] = []
var selected_level: String = "res://scenes/levels/valley.tscn"
var selected_class: String = "res://scenes/player_classes/spearman.tscn"
var in_world: bool = true
var is_loaded: bool = false
var legacy: int = 0
signal loaded


func _ready() -> void:
	Measure.start("load_state")
	var d: Variant = Persistence.load_state()
	if d != null:
		#unlocks.assign(d.get("unlocks", unlocks))
		selected_class = d.get("selected_class", selected_class)
		selected_level = d.get("selected_level", selected_level)
		in_world = d.get("in_world", in_world)
		legacy = d.get("legacy", legacy)
	is_loaded = true
	loaded.emit()
	Measure.finish("load_state")
	
func to_json() -> Dictionary:
	return {
		#"unlocks": unlocks,
		"selected_level": selected_level,
		"selected_class": selected_class,
		"in_world": in_world,
		"legacy": legacy
	}


func set_selected_level(level: LevelBlueprint) -> void:
	selected_level = level.scene_file_path
	Persistence.save_state(to_json())

func set_selected_class(player_class: PlayerClass) -> void:
	selected_class = player_class.scene_file_path
	Persistence.save_state(to_json())

func set_in_world(w: bool) -> void:
	in_world = w
	Persistence.save_state(to_json())

func add_legacy(change: int) -> void:
	legacy += change
	Persistence.save_state(to_json())

func save() -> void:
	Persistence.save_state(to_json())
