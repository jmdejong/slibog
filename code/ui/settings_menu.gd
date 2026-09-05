extends Control


func _ready() -> void:
	%QualitySelector.select(%QualitySelector.get_item_index(Config.performance))
	%CheatsButton.set_pressed_no_signal(Config.cheats_enabled)
	%DebugInfoToggle.set_pressed_no_signal(Config.debug_info_enabled)

func click_elsewhere() -> void:
	$SettingsButton.button_pressed = false
	$SettingsButton.release_focus()

func _on_quality_selector_item_selected(index: int) -> void:
	Config.set_performance(%QualitySelector.get_item_id(index))

func _on_cheats_button_toggled(toggled_on: bool) -> void:
	Config.set_cheats(toggled_on)

func _on_debug_info_toggle_toggled(toggled_on: bool) -> void:
	Config.set_debug_info(toggled_on)
