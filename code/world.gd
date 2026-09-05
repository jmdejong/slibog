class_name World
extends Node3D

var level_blueprint: String
var world_seed: int
var monster_json: Dictionary = {}
var level: LevelWorld

func _ready() -> void:
	get_tree().call_group("spawners", "initialize", monster_json)
	save()
	measure()

func measure() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	Measure.finish("open_world")

func add_player(player: Player):
	$Players.add_child(player)

func add_new_player(player_class: PlayerClass) -> void:
	var player: Player = player_class.player()
	player.transform = level.spawn_transform()
	add_player(player)

static func setup(blueprint: LevelBlueprint, world_seed_: int) -> World:
	var world: World = preload("res://scenes/world.tscn").instantiate()
	var level: Node3D = blueprint.generate(world_seed_)
	world.get_node("Level").add_child(level)
	world.level = level
	world.level_blueprint = blueprint.scene_file_path
	world.world_seed = world_seed_
	return world

static func from_json(json: Dictionary) -> World:
	var blueprint_: LevelBlueprint = load(json.blueprint).instantiate()
	var world: World = setup(blueprint_, json.seed)
	var version_match: bool = world.level.version == json.blueprint_version
	if version_match:
		world.monster_json = json.monsters
	else:
		printerr("Savefile mismatches level generation version. Saved: " + str(json.blueprint_version) + ", current: " + str(world.level.version))
	if json.player.size() > 0:
		var player: Player = Player.from_json(json.player[0])
		if not version_match:
			player.transform = world.level.spawn_transform()
		world.add_player(player)

	return world


func to_json() -> Dictionary:
	var spawners_json: Dictionary = {}
	get_tree().call_group("spawners", "add_json", spawners_json)
	#print(spawn)
	return {
		"blueprint": level_blueprint,
		"blueprint_version": level.version,
		"seed": world_seed,
		"monsters": spawners_json,
		"player": $Players.get_children().map(func(player: Player): return player.to_json())
	}

func save() -> void:
	Persistence.save_world(to_json())
