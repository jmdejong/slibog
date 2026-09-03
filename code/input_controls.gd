class_name InputControls
extends Node

const MOUSE_SENSITIVITY: float = 0.003
const tap_timeout_msec: int = 500

signal toggle_gravity
signal rotate_view(drot: Vector2)
signal attack
signal start_sprint
signal stop_sprint
signal game_click

var touch_enabled: bool = false
var touch_has_dragged: bool = true
var touch_started: bool = false
#var tap_indices: Dictionary[int, int] = {}

class ActiveTouch:
	var original_position: Vector2
	var start_timestamp_msec: int
	var position: Vector2
	func _init(pos: Vector2):
		original_position = pos
		position = pos
		start_timestamp_msec = Time.get_ticks_msec()
	func is_tap() -> bool:
		#prits(tap_check, position, original_position, Time.get_ticks_msec() - start_timestamp_msec 
		return position.distance_to(original_position) < 5 and Time.get_ticks_msec() - start_timestamp_msec < 500
		

var active_touches: Dictionary[int, ActiveTouch]
#var touch_positions: Dictionary[int, Vector2]

var wants_pointer: bool = true:
	set(p):
		wants_pointer = p
		if not p:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func horizontal_movement() -> Vector2:
	return (Input.get_vector("left", "right", "forwards", "backwards") + $%MoveJoystick.touch_value().limit_length()).limit_length()

func jump() -> bool:
	return Input.is_action_pressed("up")

func vertical_movement() -> float:
	return Input.get_axis("down", "up")

func fly_sprint() -> bool:
	return Input.is_action_pressed("sprint")

func _unhandled_input(event: InputEvent) -> void:
	if !touch_enabled and (event is InputEventScreenDrag or event is InputEventScreenTouch):
		%TouchUi.visible = true
		touch_enabled = true
		game_click.emit()
	
	if event is InputEventScreenDrag and event.index != %MoveJoystick.touch_index:
		var drot: Vector2 = (event.position - active_touches[event.index].position) / get_window().size.y * PI
		rotate_view.emit(drot)
		active_touches[event.index].position = event.position
		#touch_positions[event.index] = event.position
		#tap_indices.erase(event.index)
	if event is InputEventScreenTouch and event.index != %MoveJoystick.touch_index:
		if event.pressed:
			active_touches[event.index] = ActiveTouch.new(event.position)
			#tap_indices[event.index] = Time.get_ticks_msec()
			#touch_positions[event.index] = event.position
		else:
			#if tap_indices.get(event.index, -999_999) > Time.get_ticks_msec() - tap_timeout_msec:
			#prints("touch release", event, active_touches.get(event.index))
			if active_touches.has(event.index) and active_touches.get(event.index).is_tap():
				attack.emit()
			active_touches.erase(event.index)
			#tap_indices.erase(event.index)
			#touch_positions.erase(event.index)
	
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("click") and wants_pointer:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		game_click.emit()

	if Input.is_action_just_pressed("toggle_gravity"):
		toggle_gravity.emit()
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_view.emit(event.relative * MOUSE_SENSITIVITY)
	if Input.is_action_just_pressed("attack"):
		attack.emit()
	if Input.is_action_just_pressed("sprint"):
		start_sprint.emit()
	if Input.is_action_just_released("sprint"):
		stop_sprint.emit()
		
	if Input.is_action_just_pressed("switch_render"):
		var vp := get_viewport()
		vp.debug_draw = (vp.debug_draw + 1) % 6 as Viewport.DebugDraw
