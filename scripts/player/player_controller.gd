extends Node2D

# SIGNALS
signal lives_changed(curr_lives)
signal queue_changed(curr_client_index: int, queue_size: int)
signal day_ended()
signal game_winned()
signal day_changed()

# CONST
@export var total_lives = 3

# STATE
var curr_lives = 3
@export var curr_status = {
	"stamp": "",
	"service": "",
	"client_type": ""
}
var curr_day = null
var curr_day_index := 0
var client_queue: Array[Client] = []
var curr_client_index = 0

# NODES
@onready var curr_state_text: Label = $"../CanvasLayer/curr_state"
@onready var curr_client_text: Label = $"../CanvasLayer/curr_client"
@onready var curr_client_sprite: Sprite2D = $"../Sprite2D"
@onready var game_over_panel: TextureRect = $"../CanvasLayer/gameOverPanel"


# Resources
@export var DAYS: Array[Day]

func _ready() -> void:
	if DAYS.is_empty():
		push_error("NO DAYS assigned!")
		return
	
	curr_day_index = 0
	curr_day = DAYS[0]
	setup_queue()
	setup_lives()
	connect_signals()
	

func connect_signals():
	SelectItem.on_item_selected.connect(on_item_selected)
	
func on_item_selected(item, value):
	curr_status[item] = value
	update_status_ui()
	

# Status
func clear_curr_status():
	curr_status = {
		"stamp": "",
		"service": "",
		"client_type": ""
	}
	update_status_ui()
	
func _on_stamp_button_button_down() -> void:
	check_document()
	
func check_document():
	var client = client_queue[curr_client_index]
	
	var correct = \
		client.service == curr_status["service"] and \
		client.type == curr_status["client_type"]
	
	if not correct:
		handle_error()
		return
		
	handle_success()

func handle_error():
	reduce_live()
	print("error")
	
func handle_success():
	clear_curr_status()
	handle_next_client()

func handle_next_day():
	print("day index: ", curr_day_index)
	curr_day_index += 1
	print("day index: ", curr_day_index)
	
	if curr_day_index >= DAYS.size():
		game_won()
		return
	day_changed.emit()
	curr_day = DAYS[curr_day_index]
	setup_queue()
	print("day ended")
	
func end_day():
	day_ended.emit()
	
# clients
func setup_client():
	var curr_client = client_queue[curr_client_index]
	
	print(curr_client_text)
	curr_client_text.text = "Name: " + curr_client.name + ",\n" + "Type: " + curr_client.type + ", \n" + "Service: " + curr_client.service
	curr_client_sprite.texture = curr_client.sprite_texture
	
#func make_client():
	#var client = Client.new()
	#client.name = "jorge"
	#client.sprite_texture = CLIENT_SPRITES.pick_random()
	#client.type = Types.CLIENT_TYPES.values().pick_random()
	#client.service = Types.SERVICES.values().pick_random()
	#return client
	
func handle_next_client():
	curr_client_index += 1
	queue_changed.emit(curr_client_index, client_queue.size())
	clear_curr_status()
	
	if curr_client_index >= client_queue.size():
		end_day()
		return
	
	setup_client()

# Queue
func setup_queue():
	#for c in range(curr_day.size):
		#client_queue.append(make_client())
	
	client_queue = curr_day.clients.duplicate()
	
	curr_client_index = 0
	queue_changed.emit(curr_client_index, client_queue.size())
	setup_client()
	
# Lives
func setup_lives():
	curr_lives = total_lives
	lives_changed.emit(curr_lives)
	
func reduce_live():
	curr_lives -= 1
	lives_changed.emit(curr_lives)
	
	if curr_lives <= 0:
		game_over_panel.visible = true

# End Game
func end_game():
	print("game ended")

# Game Won
func game_won():
	game_winned.emit()

# UI
func update_status_ui():
	curr_state_text.text =  "Type: " + curr_status["client_type"] + ", \n" + "Service: " + curr_status["service"]
	
	


func _on_next_day_button_button_down() -> void:
	handle_next_day()
