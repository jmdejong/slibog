extends CheckButton

func _ready() -> void:
	set_pressed_no_signal(Config.cheats_enabled)

func _on_toggled(toggled_on: bool) -> void:
	Config.set_cheats(toggled_on)
