extends Control
class_name InkBottle

# Textures
@export var normal_texture: Texture2D
@export var hover_texture: Texture2D
@export var ink_time := 2.0

var is_inking := false
var elapsed_ink_time := 0.0
var current_stamp: StampItem = null
var animation_time := 0.0

@onready var texture_rect: TextureRect = $TextureRect
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var stamp_slot: Control = $StampSlot

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if normal_texture and texture_rect:
		texture_rect.texture = normal_texture
	
	if progress_bar:
		progress_bar.visible = false

func _process(delta):
	if not is_inking:
		return
	
	elapsed_ink_time += delta
	if progress_bar:
		progress_bar.value = elapsed_ink_time
	
	# Animate stamp dipping into ink (pivot at bottom, tip goes down)
	if current_stamp:
		animation_time += delta * 6.0
		# Dipping motion: rotate forward to dip, then back up
		var dip_angle = sin(animation_time) * 0.3  # ~17 degrees rotation
		current_stamp.rotation = dip_angle
		# Move down slightly when dipping forward
		current_stamp.position.y = abs(sin(animation_time)) * 8.0
		# Set pivot to bottom center for realistic dipping
		current_stamp.pivot_offset = Vector2(current_stamp.size.x / 2, current_stamp.size.y)
	
	if elapsed_ink_time >= ink_time:
		finish_inking()

func start_inking(stamp: StampItem):
	if is_inking:
		return
	
	current_stamp = stamp
	current_stamp.start_inking()
	
	# Move stamp to slot on ink bottle
	if stamp.get_parent():
		stamp.get_parent().remove_child(stamp)
	stamp_slot.add_child(stamp)
	stamp.position = Vector2.ZERO
	
	is_inking = true
	elapsed_ink_time = 0.0
	animation_time = 0.0
	
	if progress_bar:
		progress_bar.max_value = ink_time
		progress_bar.value = 0.0
		progress_bar.visible = true

func finish_inking():
	is_inking = false
	
	if progress_bar:
		progress_bar.visible = false
	
	if current_stamp:
		# Reset animation transforms
		current_stamp.position = Vector2.ZERO
		current_stamp.rotation = 0.0
		current_stamp.pivot_offset = Vector2.ZERO
		current_stamp.set_ready()
		print("Stamp is now ready!")
	
	# Keep stamp in slot - don't clear reference until dragged away

func on_stamp_taken(stamp: StampItem):
	if current_stamp == stamp:
		current_stamp = null

func _can_drop_data(_pos, data):
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if not data.has("type"):
		return false
		
	if is_inking or current_stamp != null:
		return false
	return data["type"] == DraggableItem.ItemType.STAMP

func _drop_data(_pos, data):
	var stamp_node = data.get("node")
	if stamp_node and stamp_node is StampItem:
		start_inking(stamp_node)
		print("Stamp started inking!")

# Hover effects
func _on_mouse_entered():
	if hover_texture and texture_rect:
		texture_rect.texture = hover_texture

func _on_mouse_exited():
	if normal_texture and texture_rect:
		texture_rect.texture = normal_texture
