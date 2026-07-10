extends Node3D

@export var is_stabbing: bool = false
@export var knockback: float = 15

func attack() -> void:
	$AnimationPlayer.play("attack")
	

func _on_hit_area_area_entered(area: Area3D) -> void:
	if not is_stabbing:
		return
	var monster: Monster = area.get_parent()
	var other_shape: CollisionShape3D = monster.collision_sphere
	var hit_pos: Vector3 = $%HitArea.global_position
	if other_shape.shape is SphereShape3D:
		hit_pos = other_shape.global_position + other_shape.global_position.direction_to(global_position) * other_shape.shape.radius
	get_node("/root/World/Effects").add_effect(preload("res://scenes/effects/impact.tscn"), hit_pos)
	
	var direction: Vector3 = %HitArea/Direction.global_position - %HitArea.global_position
	direction.y = 0;
	var knock: Vector3 = direction.normalized() * knockback
	monster.hit(10, knock, owner)
