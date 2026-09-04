extends Node


var unlocks: Array[StringName] = []
var selected_level: String = "res://scenes/levels/valley.tscn"
var selected_class: String = "res://scenes/player_classes/spearman.tscn"
var in_world: bool = true
var is_loaded: bool = false
signal loaded


func _ready() -> void:
	var d: Variant = Persistence.load_state()
	if d != null:
		unlocks.assign(d.get("unlocks", unlocks))
		selected_class = d.selected_class
		selected_level = d.selected_level
		in_world = d.in_world
	is_loaded = true
	loaded.emit()
	
func to_json() -> Dictionary:
	return {
		"unlocks": unlocks,
		"selected_level": selected_level,
		"selected_class": selected_class,
		"in_world": in_world
	}


func set_selected_level(level: LevelBlueprint) -> void:
	selected_level = level.scene_file_path
	Persistence.save_state.call_deferred(to_json())

func set_selected_class(player_class: PlayerClass) -> void:
	selected_class = player_class.scene_file_path
	Persistence.save_state.call_deferred(to_json())

func set_in_world(w: bool) -> void:
	in_world = w
	Persistence.save_state.call_deferred(to_json())
