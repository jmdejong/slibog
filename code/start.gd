extends Node

var world: World
#var generate_progress()

func _ready() -> void:
	#world = load("res://scenes/world.tscn").instantiate()
	if State.is_in_world():
		generate_world.call_deferred()
	else:
		get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")

func generate_world() -> void:
	var world_json: Variant = State.load_world()
	if world_json != null and world_json is Dictionary:
		world = World.from_json(world_json)
	if world == null:
		world = World.setup(
			State.selected_level(),
			randi()
		)
		world.player_to_spawn = State.selected_class()
	get_tree().change_scene_to_node.call_deferred(world)


func _draw() -> void:
	pass
