extends Node

const state_path: String = "user://state.json"
const world_path: String = "user://world.json"



class SaveState:
	var unlocks: Array[StringName] = []
	var selected_level: String = "res://scenes/levels/valley.tscn"
	var selected_class: String = "res://scenes/player_classes/spearman.tscn"
	var in_world: bool = true
	
	static func from_variant(d: Dictionary) -> SaveState:
		var save_state: SaveState = SaveState.new()
		save_state.unlocks.assign(d.unlocks)
		save_state.selected_level = d.selected_level
		save_state.selected_class = d.selected_class
		save_state.in_world = d.in_world
		return save_state
	
	func to_variant() -> Dictionary:
		return {
			"unlocks": unlocks,
			"selected_level": selected_level,
			"selected_class": selected_class,
			"in_world": in_world
		}

@onready var state = load_state()

func selected_level() -> LevelBlueprint:
	return load(state.selected_level).instantiate()

func selected_class() -> PlayerClass:
	return load(state.selected_class).instantiate()

func is_in_world() -> bool:
	return state.in_world

func set_selected_level(level: LevelBlueprint) -> void:
	state.selected_level = level.scene_file_path
	save_state.call_deferred()

func set_selected_class(player_class: PlayerClass) -> void:
	state.selected_class = player_class.scene_file_path
	save_state.call_deferred()

func set_in_world(w: bool) -> void:
	state.in_world = w
	save_state.call_deferred()

func load_state() -> SaveState:
	var file: FileAccess = FileAccess.open(state_path, FileAccess.READ)
	if file == null:
		return SaveState.new()
	var content: String = file.get_as_text()
	return SaveState.from_variant(JSON.parse_string(content))

func save_state():
	save_json(state.to_variant(), state_path)
	
func load_world() -> Variant:
	var file: FileAccess = FileAccess.open(world_path, FileAccess.READ)
	if file == null:
		return null
	var content: String = file.get_as_text()
	return JSON.parse_string(content)

func save_world(json: Variant):
	save_json(json, world_path)

func save_json(json: Variant, path: String):
	var text: String = JSON.stringify(json)
	var temp_path: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	file.store_string(text)
	DirAccess.rename_absolute(temp_path, path)
