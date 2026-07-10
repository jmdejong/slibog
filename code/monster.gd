class_name Monster;
extends CharacterBody3D
var health: float = 30

var target: Node3D = null
var home: Node3D = null
var forget_range: float = 64
var attack_range: float = 2
var cooldown: float = 0
var speed: float = 3
var knockback_duration: float = 0
var knockback_max_duration: float = 0.6
var knockback_dir: Vector3 = Vector3.ZERO
var reconsider_timeout: float = 0
var dead: bool = false
@onready var collision_sphere: CollisionShape3D = $Hitbox/CollisionShape3D

func hit(damage: float, knockback: Vector3, by: Node3D) -> void:
	target = by
	health -= damage
	knockback_duration = knockback_max_duration
	knockback_dir = knockback
	if health <= 0:
		dead = true
		process_mode = Node.PROCESS_MODE_DISABLED
		$AnimationPlayer.play("die")
		await $AnimationPlayer.animation_finished
		queue_free()

func alert_to_target(t: Node3D) -> void:
	if target == null or global_position.distance_squared_to(t.global_position) < global_position.distance_squared_to(target.global_position):
		target = t

func _physics_process(delta: float) -> void:
	var vy: float = velocity.y
	if knockback_duration > 0:
		var kd: float = knockback_duration / knockback_max_duration
		velocity = knockback_dir * kd*kd
	if not is_instance_valid(target) or target.dead:
		target = null
	if knockback_duration <= 0 and cooldown <= 0 and not dead:
		if target == null:
			if reconsider_timeout <= 0:
				reconsider_timeout = randf_range(0.8, 2)
				
				if randf() < 0.3 or home != null and global_position.distance_to(home.global_position) > home.roam_range:
					var rc := Vector3.FORWARD.rotated(Vector3.UP, 2 * PI * randf())
					var to: Vector3
					if home != null:
						to = home.global_position + rc * home.roam_range
					else:
						to = global_position + rc * 10
					to.y = global_position.y
					look_at(to)
					velocity = (to - global_position).normalized() * speed
					reconsider_timeout = min(reconsider_timeout, global_position.distance_to(to) * speed)
				else:
					velocity = Vector3.ZERO
		else:
			var target_diff = target.global_position - global_position
			var target_distance: float = target_diff.length()
			if target_distance > forget_range:
				target = null
			else:
				var target_direction = target_diff.normalized()
				look_at(Vector3(target.position.x, 0, target.position.z))
				if target_distance <= attack_range:
					cooldown = 1
					$AnimationPlayer.play("attack")
					velocity = Vector3.ZERO
				else:
					velocity = target_direction * speed
	velocity.y = vy
	velocity += get_gravity()
	move_and_slide()
	cooldown -= delta
	knockback_duration -= delta
	reconsider_timeout -= delta

func do_attack() -> void:
	prints($AttackArea.get_overlapping_areas())
	for area: Area3D in $AttackArea.get_overlapping_areas():
		var victim: Node3D = area.get_parent()
		victim.hit(10)
