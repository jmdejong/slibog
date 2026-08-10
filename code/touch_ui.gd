class_name TouchUi
extends Control


var touch_enabled: bool = false
var touch_has_dragged: bool = true
var touch_started: bool = false

func _input(event: InputEvent) -> void:
	if !touch_enabled and (event is InputEventScreenDrag or event is InputEventScreenTouch):
		visible = true
		touch_enabled = true

func _on_click_area_gui_input(event: InputEvent) -> void:
	#prints("some gui event", event)
	if event is InputEventScreenTouch and event.pressed:
		touch_has_dragged = false
		touch_started = true
	if event is InputEventScreenTouch and not event.pressed and not touch_has_dragged:
		touch_started = false
		#print("attack!")
		Input.action_press("attack")
		get_parent().artificial_input.emit()
		Input.action_release("attack")
	if event is InputEventScreenDrag:
		touch_has_dragged = true
		get_parent().rotate_view.emit(-event.relative / get_window().size.y)
		
