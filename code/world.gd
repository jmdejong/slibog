class_name World
extends Node3D

var blueprint: LevelBlueprint
var world_seed: int
var monster_json: Dictionary = {}
var spawn_transform: Transform3D

func _ready() -> void:
	get_tree().call_group("spawners", "initialize", monster_json)

func add_player(player: Player):
	$Players.add_child(player)

func add_new_player(player_class: PlayerClass) -> void:
	var player: Player = player_class.player()
	player.transfrom = spawn_transform
	add_player(player)

static func setup(blueprint_: LevelBlueprint, world_seed_: int) -> World:
	var world: World = preload("res://scenes/world.tscn").instantiate()
	var level: Node3D = blueprint_.generate(world_seed_)
	world.get_node("Level").add_child(level)
	world.spawn_transform = level.get_node("Spawn").transform
	world.blueprint = blueprint_
	world.world_seed = world_seed_
	return world

static func from_json(json: Dictionary) -> World:
	var blueprint_: LevelBlueprint = load(json.blueprint).instantiate()
	var version_match: bool = blueprint_.version == json.blueprint_version
	if not version_match:
		printerr("Savefile mismatches level generation version. Saved: " + json.blueprint_version + ", current: " + blueprint_.version)
	var world: World = setup(blueprint_, json.seed)
	if version_match:
		world.monster_json = json.monsters
	if json.player.size() > 0:
		var player: Player = Player.from_json(json.player[0])
		if not version_match:
			player.transform = world.spawn_transform
		world.add_player(player)

	return world


func to_json() -> Dictionary:
	var spawners_json: Dictionary = {}
	get_tree().call_group("spawners", "add_json", spawners_json)
	#print(spawn)
	return {
		"blueprint": blueprint.scene_file_path,
		"blueprint_version": blueprint.version,
		"seed": world_seed,
		"monsters": spawners_json,
		"player": $Players.get_children().map(func(player: Player): return player.to_json())
	}

func save() -> void:
	State.save_world(to_json())
