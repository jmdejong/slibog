class_name Weapon
extends Node3D

@export var attack_single: bool = false
@export var is_stabbing: bool = false:
	set(val):
		is_stabbing = val
		if val:
			for area: Area3D in $%HitArea.get_overlapping_areas():
				do_attack(area.get_parent())
@export var knockback: float = 15
var player: Player

func _ready() -> void:
	%HitArea.connect("area_entered", _on_hit_area_area_entered)

func attack() -> void:
	$AnimationPlayer.play("attack")
	

func _on_hit_area_area_entered(area: Area3D) -> void:
	if not is_stabbing:
		return
	var monster: Monster = area.get_parent()
	do_attack(monster)
	if attack_single:
		is_stabbing = false

func do_attack(monster: Monster) -> void:
	if monster.dead:
		return
	var other_shape: CollisionShape3D = monster.collision_sphere
	var hit_pos: Vector3 = $%HitArea.global_position
	if other_shape.shape is SphereShape3D:
		hit_pos = other_shape.global_position + other_shape.global_position.direction_to(global_position) * other_shape.shape.radius
	get_node("/root/World/Effects").add_effect(preload("res://scenes/effects/impact.tscn"), hit_pos)
	
	var direction: Vector3 = monster.global_position - global_position
	direction.y = 0;
	var knock: Vector3 = direction.normalized() * knockback
	monster.hit(10, knock, player)
