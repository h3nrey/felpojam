extends Control
class_name ComputerController

# Scenes
@export var popup_scene: PackedScene
@export var service_button_scene: PackedScene

# Service icons
@export var death_icon: Texture2D
@export var marriage_icon: Texture2D
@export var inheritance_icon: Texture2D

# Textures
@export var hover_texture: Texture2D
@export var normal_texture: Texture2D
@onready var texture_rect: TextureRect = $TextureRect

# Animation settingsz
@export var animation_duration: float = 0.25
@export var popup_offset: Vector2 = Vector2(-50, -150)

var service_names = {
	Types.ServiceType.DEATH: "Morte",
	Types.ServiceType.MARRIAGE: "Casamento",
	Types.ServiceType.INHERITANCE: "Herança"
}

var popup: PanelContainer
var service_label: Label
var services_container: HBoxContainer
var is_popup_visible := false
var is_animating := false
var tween: Tween

func _ready():
	_create_popup()
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	if normal_texture and texture_rect:
		texture_rect.texture = normal_texture

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_animating:
			EventBus.sfx_click.emit()
			toggle_popup()

func toggle_popup():
	if is_popup_visible:
		_animate_popup_close()
	else:
		_animate_popup_open()

func close_popup():
	if is_popup_visible and not is_animating:
		_animate_popup_close()

func _animate_popup_open():
	is_animating = true
	is_popup_visible = true
	popup.visible = true
	EventBus.sfx_popup_open.emit()
	
	popup.scale = Vector2(0.8, 0.8)
	popup.modulate.a = 0.0
	popup.position = popup_offset + Vector2(0, 20)
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(popup, "scale", Vector2.ONE, animation_duration)
	tween.tween_property(popup, "modulate:a", 1.0, animation_duration).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(popup, "position", popup_offset, animation_duration).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_callback(func(): is_animating = false)

func _animate_popup_close():
	is_animating = true
	EventBus.sfx_popup_close.emit()
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(popup, "scale", Vector2(0.8, 0.8), animation_duration)
	tween.tween_property(popup, "modulate:a", 0.0, animation_duration).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(popup, "position", popup_offset + Vector2(0, 20), animation_duration).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_callback(_on_close_animation_finished)

func _on_close_animation_finished():
	popup.visible = false
	is_popup_visible = false
	is_animating = false

func _create_popup():
	popup = popup_scene.instantiate()
	add_child(popup)
	popup.position = popup_offset
	popup.pivot_offset = popup.size / 2
	
	services_container = popup.get_node("%ServicesContainer")
	service_label = popup.get_node("%ServiceLabel")
	
	_create_service_button(Types.ServiceType.DEATH, death_icon)
	_create_service_button(Types.ServiceType.MARRIAGE, marriage_icon)
	_create_service_button(Types.ServiceType.INHERITANCE, inheritance_icon)

func _create_service_button(service_type: Types.ServiceType, icon: Texture2D):
	var button = service_button_scene.instantiate()
	button.get_node("%Icon").texture = icon

	button.mouse_entered.connect(_on_service_hover.bind(service_type))
	button.mouse_exited.connect(_on_service_hover_end)
	
	button.drag_started.connect(close_popup)
	
	services_container.add_child(button)

	button.service_type = service_type
	button.icon = icon

func _on_service_hover(service_type: Types.ServiceType):
	service_label.text = service_names[service_type]

func _on_service_hover_end():
	service_label.text = ""

func _on_mouse_entered():
	if hover_texture and texture_rect:
		texture_rect.texture = hover_texture

func _on_mouse_exited():
	if normal_texture and texture_rect and not is_popup_visible:
		texture_rect.texture = normal_texture
