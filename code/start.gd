extends Node


func _ready() -> void:
	print("Starting slibog")
	initialize.call_deferred()

func initialize():
	await(get_tree().create_timer(0.2).timeout)
	#if not State.is_loaded:
		#await State.loaded
	assert(State.is_loaded, "Savestate not yet loaded")
	if State.in_world:
		print("go to world")
		Measure.start("load_world")
		var world: World
		var world_json: Variant = Persistence.load_world()
		if world_json == null:
			prints("no world exists yet")
			world = World.setup(
				load(State.selected_level).instantiate(),
				randi()
			)
			world.add_new_player(load(State.selected_class).instantiate())
		else:
			print("load world from json")
			world = World.from_json(world_json)
		Measure.finish("load_world")
		Measure.start("open_world")
		get_tree().change_scene_to_node.call_deferred(world)
	else:
		print("go to menu")
		Measure.start("open_menu")
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _draw() -> void:
	pass
