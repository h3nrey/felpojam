extends HBoxContainer

@onready var label: Label = $Label


func _on_player_controller_queue_changed(index: int, queue_size: int) -> void:
	print("queue setted: " + str(index))
	label.text = str(index+1) + " / " + str(queue_size)
