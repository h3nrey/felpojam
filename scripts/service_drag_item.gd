extends Control
class_name ServiceDragItem

signal drag_started

# These will be set by ComputerController
var service_type: Types.ServiceType
var icon: Texture2D

func _get_drag_data(_pos):
	drag_started.emit()
	EventBus.sfx_drag_start.emit()
	
	# Create preview on high-layer canvas
	var container = Control.new()
	container.custom_minimum_size = Vector2(48, 48)
	container.size = Vector2(48, 48)
	
	var preview = TextureRect.new()
	preview.texture = icon
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	container.add_child(preview)
	
	# Use DragLayer singleton for high z-order preview
	if has_node("/root/DragLayer"):
		get_node("/root/DragLayer").set_preview(container)
	else:
		set_drag_preview(container)
	
	return {
		"type": DraggableItem.ItemType.SERVICE,
		"value": service_type,
		"icon": icon,
		"node": self
	}

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		EventBus.sfx_drag_end.emit()
		if has_node("/root/DragLayer"):
			get_node("/root/DragLayer").clear_preview()
