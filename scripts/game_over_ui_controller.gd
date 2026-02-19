extends TextureRect



func _on_try_again_button_button_down() -> void:
	get_tree().reload_current_scene()
