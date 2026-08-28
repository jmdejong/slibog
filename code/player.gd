class_name Player
extends CharacterBody3D

const walk_speed: float = 4.3
const sprint_speed: float = 8
const debug_sprint_mult: float = 10
const gravity: float = 9.81
const jump_speed: float = 5

var gravity_enabled: bool = true
var max_health: float = 30
var health: float = max_health
var heal_rate = 0.25
var dead: bool = false
var knockback_duration: float = 0
var knockback_max_duration: float = 0.3
var knockback_dir: Vector3 = Vector3.ZERO
var is_sprinting: bool = false
var stamina: float = 10
var max_stamina: float = 10
var stamina_regen_rate: float = 1
var sprint_stamina_drain: float = 3
var min_sprint_start_stamina: float = 2

@onready var weapon: Weapon = %Hand.get_child(0)

signal viewpoint_changed(pos: Vector3)

func _ready() -> void:
	set_performance()
	update_health_bar()
	update_stamina_bar()

func set_performance() -> void:
	if Config.performance == Config.Perf.FAST:
		%AlerterShape.shape.radius = 64
		%Camera.far = 96
	elif Config.performance == Config.Perf.PRETTY:
		%AlerterShape.shape.radius = 128
		%Camera.far = 500

func _physics_process(delta: float) -> void:
	
	var prev_health: float = health
	var prev_stamina: float = stamina
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
	if prev_health != health:
		update_health_bar()
	if floor(stamina) <= 0:
		is_sprinting = false
	if dead:
		stamina = max(stamina - 10 * delta, 0)
	elif is_sprinting:
		stamina = max(stamina - sprint_stamina_drain * delta, 0)
	else:
		stamina = min(stamina + stamina_regen_rate * delta, max_stamina)
	if prev_stamina != stamina:
		update_stamina_bar()
	%OverlayUi.set_info_text("fps: %3.1f" % Engine.get_frames_per_second())


func rotate_view(drot: Vector2) -> void:
	%Head.rotation.x = clamp(%Head.rotation.x - drot.y, -PI/2, PI/2)
	if dead:
		%Head.rotate_y(-drot.x)
	else:
		rotate_y(-drot.x)
		%Hand.rotation.x = %Head.rotation.x * 0.8

func update_health_bar():
	%OverlayUi.set_health(health, max_health)

func update_stamina_bar():
	%OverlayUi.set_stamina(stamina, max_stamina)

func hit(damage: float, knockback: Vector3, _by: Monster) -> void:
	health -= damage
	update_health_bar()
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
