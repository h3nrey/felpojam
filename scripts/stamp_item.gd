extends DraggableItem
class_name StampItem

enum StampState { EMPTY, INKING, READY }

@export var service_type: Types.ServiceType

# Textures
@export var normal_texture: Texture2D
@export var hover_texture: Texture2D

var state: StampState = StampState.EMPTY

var original_parent: Node = null
var original_position: Vector2 = Vector2.ZERO
var is_dragging := false
var drop_successful := false

func _ready():
	item_type = ItemType.STAMP
	item_value = service_type
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if normal_texture:
		icon = normal_texture
	
	super._ready()

func start_inking():
	if state == StampState.EMPTY:
		state = StampState.INKING
		update_visual()

func set_ready():
	state = StampState.READY
	update_visual()

func use_stamp() -> bool:
	if state == StampState.READY:
		state = StampState.EMPTY
		update_visual()
		return true
	return false

func is_ready() -> bool:
	return state == StampState.READY

func update_visual():
	match state:
		StampState.EMPTY:
			modulate = Color(0.5, 0.5, 0.5)
		StampState.INKING:
			modulate = Color(0.7, 0.7, 1.0)
		StampState.READY:
			modulate = Color.WHITE

func _get_drag_data(_pos):
	# Can't drag while inking
	if state == StampState.INKING:
		return null
	
	# Store original position for snap-back
	original_parent = get_parent()
	original_position = position
	is_dragging = true
	drop_successful = false
	
	var data = super._get_drag_data(_pos)
	data["stamp_state"] = state
	data["service_type"] = service_type
	
	# Notify parent (InkBottle) that stamp is being taken
	if get_parent() and get_parent().get_parent() and get_parent().get_parent().has_method("on_stamp_taken"):
		get_parent().get_parent().on_stamp_taken(self)
	
	return data

func mark_drop_successful():
	drop_successful = true

func _notification(what):
	super._notification(what)
	if what == NOTIFICATION_DRAG_END:
		if is_dragging and not drop_successful:
			# Return to original position and reset state
			return_to_origin()
		is_dragging = false

func return_to_origin():
	if original_parent and is_instance_valid(original_parent):
		# Remove from current parent if different
		if get_parent() and get_parent() != original_parent:
			get_parent().remove_child(self)
			original_parent.add_child(self)
		
		position = original_position
		
		# Reset stamp to empty state when returned
		if state == StampState.READY:
			state = StampState.EMPTY
			update_visual()
			print("Stamp returned - ink cleared")

func _on_mouse_entered():
	if sprite:
		sprite.modulate = Color(1.2, 1.2, 1.2, 1.0)  # Brighten

func _on_mouse_exited():
	if sprite:
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Normal
