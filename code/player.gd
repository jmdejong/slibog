class_name Player
extends CharacterBody3D


const MOUSE_SENSITIVITY: float = 0.003
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
var dead_and_gone: bool = false
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
	update_health_bar()
	update_stamina_bar()

func _physics_process(delta: float) -> void:
	
	var prev_health: float = health
	var prev_stamina: float = stamina
	var input_movement: Vector2 = Input.get_vector("left", "right", "forwards", "backwards")
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
		if Input.is_action_pressed("up") and is_on_floor() and not dead:
			movement.y = jump_speed
	else:
		movement.y = walk_speed * Input.get_axis("down", "up")# Input.is_action_pressed("up")) - float(Input.is_action_pressed("down")))
		if Input.is_action_pressed("sprint"):
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

func _input(event: InputEvent) -> void:
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("click") and not dead_and_gone:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("toggle_gravity"):
		gravity_enabled = not gravity_enabled
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		%Head.rotation.x = clamp(%Head.rotation.x - event.relative.y * MOUSE_SENSITIVITY, -PI/2, PI/2)
		if dead:
			%Head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		else:
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			%Hand.rotation.x = %Head.rotation.x * 0.8
	if Input.is_action_just_pressed("attack") and not dead:
		weapon.attack()
	if Input.is_action_just_pressed("sprint") and stamina > min_sprint_start_stamina:
		is_sprinting = true
	if Input.is_action_just_released("sprint"):
		is_sprinting = false

func update_health_bar():
	$UI.set_health(health, max_health)

func update_stamina_bar():
	$UI.set_stamina(stamina, max_stamina)

func _on_alerter_area_entered(area: Area3D) -> void:
	var monster: Monster = area.get_parent()
	monster.alert_to_target(self)

func hit(damage: float, knockback: Vector3, _by: Monster) -> void:
	health -= damage
	update_health_bar()
	knockback_duration = knockback_max_duration
	knockback_dir = knockback
	if floor(health) <= 0:
		die()

func die() -> void:
	dead = true
	$AnimationPlayer.play("die")
	await get_tree().create_timer(2).timeout
	dead_and_gone = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$UI.end_run()

func set_weapon(new_weapon: Weapon) -> void:
	for child in %Hand.get_children():
		child.queue_free()
	new_weapon.player = self
	%Hand.add_child(new_weapon)
	weapon = new_weapon
