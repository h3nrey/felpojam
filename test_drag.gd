extends Control
func _notification(what):
if what == NOTIFICATION_DRAG_END:
print(get_viewport().gui_is_drag_successful())
