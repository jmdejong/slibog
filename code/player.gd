class_name Player
extends CharacterBody3D

const walk_speed: float = 4.3
const sprint_speed: float = 8
const debug_sprint_mult: float = 10
const gravity: float = 9.81
const jump_speed: float = 5

var gravity_enabled: bool = true
var base_max_health: float = 20
var max_health: float:
	get():
		return base_max_health + player_level * 3
var health: float = max_health
var prev_health: float = -1
var heal_rate = 0.25
var dead: bool = false
var knockback_duration: float = 0
var knockback_max_duration: float = 0.3
var knockback_dir: Vector3 = Vector3.ZERO
var is_sprinting: bool = false
var stamina: float = 10
var base_max_stamina: float = 10
var max_stamina: float:
	get():
		return base_max_stamina + player_level * 2
var prev_stamina: float = -1
var stamina_regen_rate: float = 1
var sprint_stamina_drain: float = 3
var min_sprint_start_stamina: float = 2
var xp: float = 0
var prev_xp: float = -1
var player_level: int = 0
var prev_level: int = -1
var current_level_xp: float = -2
var next_level_xp: float = -1

@onready var weapon: Weapon = %Hand.get_child(0)

signal viewpoint_changed(pos: Vector3)

func _ready() -> void:
	set_performance()
	update_bars()
	calculate_level()

func set_performance() -> void:
	if Config.performance == Config.Perf.FAST:
		%AlerterShape.shape.radius = 64
		%Camera.far = 96
	elif Config.performance == Config.Perf.PRETTY:
		%AlerterShape.shape.radius = 128
		%Camera.far = 500

func _physics_process(delta: float) -> void:
	var input_movement: Vector2 = %InputControls.horizontal_movement()
	var movement: Vector3 = Vector3.ZERO
	
	if knockback_duration > 0:
		var kd: float = knockback_duration / knockback_max_duration
		movement = knockback_dir * kd*kd
	elif not dead:
		movement = (Vector3(input_movement.x, 0, input_movement.y)) \
			.rotated(Vector3.UP, self.rotation.y)
		if is_sprinting:
			movement *= sprint_speed
		else:
			movement *= walk_speed
	
	if gravity_enabled:
		movement.y = velocity.y + get_gravity().y*delta
		if %InputControls.jump() and is_on_floor() and not dead:
			movement.y = jump_speed
	else:
		movement.y = walk_speed * %InputControls.vertical_movement()
		if %InputControls.fly_sprint():
			movement *= debug_sprint_mult
	
	velocity = movement
	move_and_slide()
	knockback_duration -= delta
	
	viewpoint_changed.emit(position)
	
	if dead:
		health = 0
	else:
		health = min(max_health, health + heal_rate * delta)
	if floor(stamina) <= 0:
		is_sprinting = false
	if dead:
		stamina = max(stamina - 10 * delta, 0)
	elif is_sprinting:
		stamina = max(stamina - sprint_stamina_drain * delta, 0)
	else:
		stamina = min(stamina + stamina_regen_rate * delta, max_stamina)
	update_bars()
	calculate_level()
	%OverlayUi.set_info_text("fps: %3.1f\npos: %3.1f, %3.1f, %3.1f" % [
		Engine.get_frames_per_second(),
		global_position.x,
		global_position.y,
		global_position.z
	])
	
	prev_health = health
	prev_stamina = stamina
	prev_xp = xp


func rotate_view(drot: Vector2) -> void:
	%Head.rotation.x = clamp(%Head.rotation.x - drot.y, -PI/2, PI/2)
	if dead:
		%Head.rotate_y(-drot.x)
	else:
		rotate_y(-drot.x)
		%Hand.rotation.x = %Head.rotation.x * 0.8

func update_bars():
	if health != prev_health:
		%OverlayUi.set_health(health, max_health)
	if stamina != prev_stamina:
		%OverlayUi.set_stamina(stamina, max_stamina)
	if xp != prev_xp:
		%OverlayUi.set_xp(xp - current_level_xp, next_level_xp - current_level_xp)


func hit(damage: float, knockback: Vector3, _by: Monster) -> void:
	health -= damage
	knockback_duration = knockback_max_duration
	knockback_dir = knockback
	if floor(health) <= 0:
		die()

func die() -> void:
	dead = true
	State.set_in_world(false)
	$AnimationPlayer.play("die")
	await get_tree().create_timer(2).timeout
	%InputControls.wants_pointer = false
	%MenuUi.end_run()

func set_weapon(new_weapon: Weapon) -> void:
	for child in %Hand.get_children():
		child.queue_free()
	new_weapon.player = self
	%Hand.add_child(new_weapon)
	weapon = new_weapon

func start_attack() -> void:
	if not dead:
		weapon.attack()

func toggle_gravity() -> void:
	gravity_enabled = !gravity_enabled

func start_sprint() -> void:
	if stamina > min_sprint_start_stamina:
		is_sprinting = true

func stop_sprint() -> void:
	is_sprinting = false

func gain_xp(amount: float) -> void:
	xp += amount

func xp_for_level(level: int) -> float:
	var l := float(level-1)
	return floor(l * l * 20)

func calculate_level() -> void:
	var level_changed: bool
	while xp >= xp_for_level(player_level + 1):
		player_level += 1
		level_changed = true
	if not level_changed:
		return
	current_level_xp = xp_for_level(player_level)
	next_level_xp = xp_for_level(player_level + 1)
	%OverlayUi.set_xp(xp - current_level_xp, next_level_xp - current_level_xp)
	%OverlayUi.set_level(player_level)



func _on_pickup_body_entered(body: PickupItem) -> void:
	body.pickup(self)
