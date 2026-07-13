class_name Player
extends CharacterBody3D


const MOUSE_SENSITIVITY: float = 0.003
const speed: float = 4.3
const sprint_mult: float = 10
const gravity: float = 9.81
const jump_speed: float = 5

var gravity_enabled: bool = true
var max_health: float = 20
var health: float = max_health
var dead: bool = false
var dead_and_gone: bool = false

@onready var weapon: Weapon = %Hand.get_child(0)

signal viewpoint_changed(pos: Vector3)

func _ready() -> void:
	update_health_bar()

func _physics_process(delta: float) -> void:
	
	var input_movement: Vector2 = Input.get_vector("left", "right", "forwards", "backwards")
	var movement: Vector3 = (Vector3(input_movement.x, 0, input_movement.y) * speed) \
		.rotated(Vector3.UP, self.rotation.y)
	if gravity_enabled:
		movement.y = velocity.y + get_gravity().y*delta
		if Input.is_action_pressed("up") and is_on_floor():
			movement.y = jump_speed
	else:
		movement.y = speed * Input.get_axis("down", "up")# Input.is_action_pressed("up")) - float(Input.is_action_pressed("down")))
		if Input.is_action_pressed("sprint"):
			movement *= sprint_mult
	
	velocity = movement
	if not dead:
		move_and_slide()
	
	viewpoint_changed.emit(position)

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

func update_health_bar():
	$UI.set_health(health, max_health)

func _on_alerter_area_entered(area: Area3D) -> void:
	var monster: Monster = area.get_parent()
	monster.alert_to_target(self)

func hit(damage: float) -> void:
	health -= damage
	update_health_bar()
	if health <= 0:
		die()

func die() -> void:
	dead = true
	$AnimationPlayer.play("die")
	await get_tree().create_timer(2).timeout
	dead_and_gone = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$UI.end_run()

func set_weapon(weapon: Weapon) -> void:
	for child in %Hand.get_children():
		child.queue_free()
	weapon.player = self
	%Hand.add_child(weapon)
