extends Node


const state_path: String = "user://state.json"
const world_path: String = "user://world.json"

func load_state() -> Variant:
	return load_json(state_path)

func save_state(json: Dictionary):
	save_json(json, state_path)
	
func load_world() -> Variant:
	return load_json(world_path)

func save_world(json: Dictionary):
	save_json(json, world_path)

func save_json(json: Variant, path: String):
	var text: String = JSON.stringify(json)
	var temp_path: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	file.store_string(text)
	DirAccess.rename_absolute(temp_path, path)

func load_json(path) -> Variant:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var content: String = file.get_as_text()
	return JSON.parse_string(content)
