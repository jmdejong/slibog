class_name Monster;
extends CharacterBody3D
var health: float = 30

@export var forget_range: float = 64
@export var attack_range: float = 2.5
@export var attack_knockback: float = 10
@export var attack_cooldown: float = 1
@export var speed: float = 3
@export var attack_damage: float = 10
@export var turn_speed: float = PI # rad/s
var knockback_duration: float = 0
var knockback_max_duration: float = 0.6
var knockback_dir: Vector3 = Vector3.ZERO
var reconsider_timeout: float = 0
var dead: bool = false

var target: Player = null
var home: Node3D = null
@onready var collision_sphere: CollisionShape3D = $Hitbox/CollisionShape3D
@onready var target_pos: Vector3 = position

var horizontal_velocity: Vector3:
	set(v):
		velocity = Vector3(v.x, velocity.y, v.z)
	get():
		return Vector3(horizontal_velocity.x, 0, horizontal_velocity.z)
enum Behavior {Waiting, Walking, Turning, Attacking, Knockedback, Dying}
var behavior: Behavior = Behavior.Waiting

func hit(damage: float, knockback: Vector3, by: Player) -> void:
	target = by
	health -= damage
	knockback_duration = knockback_max_duration
	knockback_dir = knockback
	behavior = Behavior.Knockedback
	$AnimationPlayer.stop()
	if health <= 0:
		die()

func die() -> void:
		dead = true
		behavior = Behavior.Dying
		horizontal_velocity = Vector3.ZERO
		#process_mode = Node.PROCESS_MODE_DISABLED
		collision_layer = 0
		collision_mask = 1
		$AnimationPlayer.play("die")
		await $AnimationPlayer.animation_finished
		queue_free()

func alert_to_target(t: Node3D) -> void:
	if target == null or global_position.distance_squared_to(t.global_position) < global_position.distance_squared_to(target.global_position):
		target = t
		plan()

func plan() -> void:
	if not is_instance_valid(target) or target.dead:
		target = null
	if behavior == Behavior.Dying or knockback_duration > 0 or is_attacking():
		return
	if not is_on_floor() and behavior != Behavior.Turning:
		behavior = Behavior.Waiting
		return
	var has_target_pos: bool = false
	if target == null:
		reconsider_timeout = randf_range(0.8, 2)
		if randf() < 0.3 or home != null and global_position.distance_to(home.global_position) > home.roam_range:
			behavior = Behavior.Walking
			var rc := Vector3.FORWARD.rotated(Vector3.UP, 2 * PI * randf())
			if home != null:
				has_target_pos = true
				target_pos = home.global_position + rc * home.roam_range
			else:
				has_target_pos = true
				target_pos = global_position + rc * 10
			target_pos.y = global_position.y
			behavior = Behavior.Walking
			start_walk()
		else:
			horizontal_velocity = Vector3.ZERO
			behavior = Behavior.Waiting
	else:
		if global_position.distance_to(target.global_position) > forget_range:
			target = null
			behavior = Behavior.Waiting
			plan.call_deferred()
		else:
			target_pos = target.global_position
			has_target_pos = true
	if has_target_pos:
		if abs(angle_to_target()) > 0.05:
			behavior = Behavior.Turning
			horizontal_velocity = Vector3.ZERO
		else:
			look_at(Vector3(target_pos.x, global_position.y, target_pos.z))
			if global_position.distance_to(target_pos) <= attack_range:
				#cooldown = attack_cooldown
				behavior = Behavior.Attacking
				$AnimationPlayer.play("attack")
				start_attack()
				await $AnimationPlayer.animation_finished
				plan()
			else:
				behavior = Behavior.Walking
				start_walk()

func angle_to_target() -> float:
	var look_dir: Vector3 = transform.basis * Vector3.FORWARD
	var target_dir: Vector3 = target_pos - global_position
	return Vector2(look_dir.x, look_dir.z).angle_to(Vector2(target_dir.x, target_dir.z))

func start_walk() -> void:
	var dif: Vector3 = target_pos - global_position
	horizontal_velocity = Vector3(dif.x, 0, dif.z).normalized() * speed
	reconsider_timeout = min(reconsider_timeout, global_position.distance_to(target_pos) * speed)

func walk() -> void:
	if reconsider_timeout <= 0:
		plan()

func _physics_process(delta: float) -> void:
	if behavior == Behavior.Waiting:
		if reconsider_timeout <= 0:
			plan()
	elif behavior == Behavior.Walking:
		walk()
	elif behavior == Behavior.Turning:
		if target != null:
			target_pos = target.global_position
		if abs(angle_to_target()) <= delta * turn_speed:
			look_at(Vector3(target_pos.x, global_position.y, target_pos.z))
			plan()
		else:
			rotate(Vector3.UP, -sign(angle_to_target()) * turn_speed * delta)
	elif behavior == Behavior.Knockedback:
		if knockback_duration > 0:
			var kd: float = knockback_duration / knockback_max_duration
			horizontal_velocity = knockback_dir * kd*kd
		else:
			plan()
	elif behavior == Behavior.Attacking:
		if not is_attacking():
			plan()
	elif behavior == Behavior.Dying:
		pass
	velocity += get_gravity() * delta
	move_and_slide()
	knockback_duration -= delta
	reconsider_timeout -= delta
	post_process(delta)

func is_attacking() -> bool:
	return $AnimationPlayer.current_animation == "attack" and $AnimationPlayer.is_playing()

func post_process(delta: float) -> void:
	pass

func start_attack() -> void:
	horizontal_velocity = Vector3.ZERO
	

func do_attack() -> int:
	var victims: int = 0
	for area: Area3D in $AttackArea.get_overlapping_areas():
		var victim: Node3D = area.get_parent()
		if victim.dead:
			continue
		victims += 1
		var direction: Vector3 = victim.global_position - global_position
		direction.y = 0;
		victim.hit(attack_damage, direction.normalized() * attack_knockback, self)
	return victims
