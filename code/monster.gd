class_name Monster;
extends CharacterBody3D
var health: float = 30

@export var forget_range: float = 48
@export var alert_range: float = 24
@export var attack_range: float = 2.5
@export var attack_knockback: float = 10
@export var attack_cooldown: float = 1
@export var speed: float = 3
@export var attack_damage: float = 10
@export var turn_speed: float = PI # rad/s
@export var xp: float = 10
var knockback_duration: float = 0
var knockback_max_duration: float = 0.6
var knockback_dir: Vector3
var knockback_strength: float
var reconsider_timeout: float = 0
var dead: bool = false
var last_random_pos_stamp: int = 0
const change_random_pos_ms: int = 2000

var target: Player = null
var home: Node3D = null
@onready var collision_sphere: CollisionShape3D = $Hitbox/CollisionShape3D
@onready var target_pos: Vector3 = position
var has_target_pos: bool = false

enum Behavior {Sleeping, Waiting, Walking, Turning, Attacking, Knockedback, Dying}
var behavior: Behavior = Behavior.Sleeping

@export var loot: Array[LootEntry] = []

func set_horizontal_velocity(vel: Vector3) -> void:
	velocity = Vector3(vel.x, velocity.y, vel.z)

func reset_horizontal_velocity() -> void:
	velocity = Vector3(0, velocity.y, 0)

func walk_to(to: Vector3, move_speed: float) -> void:
	var dir: Vector3 = to - global_position
	var hdir: Vector2 = Vector2(dir.x, dir.z)
	var hvel: Vector2 = hdir.normalized() * move_speed
	velocity = Vector3(hvel.x, velocity.y, hvel.y)

func hit(damage: float, knockback: Vector3, by: Player) -> void:
	target = by
	health -= damage
	knockback_duration = knockback_max_duration
	knockback_dir = knockback.normalized()
	knockback_strength = knockback.length()
	behavior = Behavior.Knockedback
	$AnimationPlayer.stop()
	if health <= 0:
		die(by)

func die(by: Player) -> void:
		dead = true
		behavior = Behavior.Dying
		reset_horizontal_velocity()
		#process_mode = Node.PROCESS_MODE_DISABLED
		collision_layer = 0
		collision_mask = 1
		if by != null:
			by.gain_xp(xp)
		for entry: LootEntry in loot:
			if randf() < entry.chance:
				var loot_item: Node3D = entry.item.instantiate()
				loot_item.position = position + Vector3(randf_range(-0.5, 0.5), 1, randf_range(-0.5, 0.5))
				loot_item.rotate_y(randf() * 2 * PI)
				add_sibling(loot_item)
				break
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
	if !%Observe.has_overlapping_areas():
		behavior = Behavior.Sleeping
		return
	if not is_on_floor() and behavior != Behavior.Turning:
		behavior = Behavior.Waiting
		return
	if target == null:
		for o: Area3D in %Observe.get_overlapping_areas():
			var player: Player = o.get_parent()
			if not player.dead and global_position.distance_to(player.global_position) < alert_range:
				target = player
	if target == null:
		reconsider_timeout = randf_range(0.8, 2)
		if randf() < 0.3 or home != null and global_position.distance_to(home.global_position) > home.roam_range:
			behavior = Behavior.Walking
			var rc := Vector3.FORWARD.rotated(Vector3.UP, 2 * PI * randf())
			if !has_target_pos or last_random_pos_stamp < Time.get_ticks_msec() - change_random_pos_ms:
				if home != null:
					has_target_pos = true
					target_pos = home.global_position + rc * home.roam_range
				else:
					has_target_pos = true
					target_pos = global_position + rc * 10
				last_random_pos_stamp = Time.get_ticks_msec()
			target_pos.y = global_position.y
			behavior = Behavior.Walking
			start_walk()
		else:
			reset_horizontal_velocity()
			behavior = Behavior.Waiting
	if target != null and (global_position.distance_to(target.global_position) > forget_range or target.dead):
		target = null
		behavior = Behavior.Waiting
		plan.call_deferred()
	if target != null:
		target_pos = target.global_position
		has_target_pos = true
	if has_target_pos:
		var tdist: float = distance_to_target()
		if abs(angle_to_target()) > 0.05 and tdist > 0.1:
			behavior = Behavior.Turning
			reset_horizontal_velocity()
		else:
			if tdist > 0.1:
				look_at(Vector3(target_pos.x, global_position.y, target_pos.z))
			if global_position.distance_to(target_pos) <= attack_range:
				if target != null:
					behavior = Behavior.Attacking
					$AnimationPlayer.play("attack")
					start_attack()
					await $AnimationPlayer.animation_finished
					plan()
				else:
					behavior = Behavior.Waiting
			else:
				behavior = Behavior.Walking
				start_walk()

func angle_to_target() -> float:
	var look_dir: Vector3 = global_basis * Vector3.FORWARD
	var target_dir: Vector3 = target_pos - global_position
	return Vector2(look_dir.x, look_dir.z).angle_to(Vector2(target_dir.x, target_dir.z))

func distance_to_target() -> float:
	if not has_target_pos:
		return 0
	return Vector2(global_position.x, global_position.z).distance_to(Vector2(target_pos.x, target_pos.z))

func start_walk() -> void:
	walk_to(target_pos, speed)
	reconsider_timeout = min(reconsider_timeout, global_position.distance_to(target_pos) * speed)

func walk() -> void:
	if reconsider_timeout <= 0:
		plan()

func _physics_process(delta: float) -> void:
	if behavior == Behavior.Sleeping:
		return
	if behavior == Behavior.Waiting:
		if reconsider_timeout <= 0:
			plan()
	elif behavior == Behavior.Walking:
		walk()
	elif behavior == Behavior.Turning:
		if target != null:
			target_pos = target.global_position
		if global_position == Vector3(target_pos.x, global_position.y, target_pos.z):
			plan()
		if abs(angle_to_target()) <= delta * turn_speed:
			look_at(Vector3(target_pos.x, global_position.y, target_pos.z))
			plan()
		else:
			rotate(Vector3.UP, -sign(angle_to_target()) * turn_speed * delta)
	elif behavior == Behavior.Knockedback:
		if knockback_duration > 0:
			var kd: float = knockback_duration / knockback_max_duration
			set_horizontal_velocity(knockback_dir * knockback_strength * kd * kd)
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

func post_process(_delta: float) -> void:
	pass

func start_attack() -> void:
	reset_horizontal_velocity()

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

func _on_observe_area_entered(area: Area3D) -> void:
	var player: Player = area.get_parent()
	if global_position.distance_to(player.global_position) < alert_range:
		alert_to_target(player)
	elif behavior == Behavior.Sleeping:
		plan()

func _on_observe_area_exited(_area: Area3D) -> void:
	if behavior != Behavior.Dying and %Observe != null and !%Observe.has_overlapping_areas():
		behavior = Behavior.Sleeping

func set_from_json(json: Dictionary) -> void:
	position.x = json.p[0]
	position.y = json.p[1]
	position.z = json.p[2]
	if json.get("dead", false):
		dead = true
	health = json.h

func to_json() -> Dictionary:
	var json: Dictionary = {
		"p": [snappedf(position.x, 0.01), snappedf(position.y, 0.01), snappedf(position.z, 0.01)],
		"h": health,
	}
	if dead:
		json.dead = true
	return json
