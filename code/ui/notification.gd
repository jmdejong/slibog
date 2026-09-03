class_name Notification
extends Label

var duration: float = 2
var fade_duration: float = 1

static func create(text_: String) -> Notification:
	var notification_: Notification = preload("res://scenes/ui/notification.tscn").instantiate()
	notification_.text = text_
	return notification_

func _process(delta: float) -> void:
	duration -= delta
	if duration < 0:
		queue_free()
	elif duration < fade_duration:
		self.modulate.a = duration / fade_duration
