extends CanvasLayer

var current_preview: Control = null

func _ready():
	layer = 100  # Very high layer to be above everything
	
func set_preview(preview: Control):
	clear_preview()
	current_preview = preview
	add_child(preview)
	
func clear_preview():
	if current_preview and is_instance_valid(current_preview):
		current_preview.queue_free()
	current_preview = null

func _process(_delta):
	if current_preview:
		current_preview.global_position = get_viewport().get_mouse_position() - current_preview.size / 2
