class_name World
extends Node3D

var blueprint: LevelBlueprint
var world_seed: int
var player_to_spawn: PlayerClass
var monster_json: Variant = null

func _ready() -> void:
	var level: Node3D = blueprint.generate(world_seed)
	$Level.add_child(level)
	if monster_json != null:
		get_tree().call_group("spawners", "set_from_json", monster_json)
	if player_to_spawn != null:
		var player: Player = player_to_spawn.player()
		player.transform = level.get_node("Spawn").transform
		add_player(player)

func add_player(player: Player):
	$Players.add_child(player)

static func setup(blueprint_: LevelBlueprint, world_seed_: int) -> World:
	var world: World = preload("res://scenes/world.tscn").instantiate()
	world.blueprint = blueprint_
	world.world_seed = world_seed_
	return world

static func from_json(json: Dictionary) -> World:
	var blueprint_: LevelBlueprint = load(json.blueprint).instantiate()
	if blueprint_.version != json.blueprint_version:
		printerr("Savefile mismatches level generation version. Saved: " + json.blueprint_version + ", current: " + blueprint_.version)
		return null
	var world: World = setup(blueprint_, json.seed)
	world.monster_json = json.monsters
	if json.player.size() > 0:
		world.add_player(Player.from_json(json.player[0]))
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
