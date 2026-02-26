extends Node

# Sound effect streams - configure in inspector or assign via code
@export var click_sound: AudioStream
@export var drag_start_sound: AudioStream
@export var drag_end_sound: AudioStream
@export var drop_success_sound: AudioStream
@export var drop_fail_sound: AudioStream
@export var popup_open_sound: AudioStream
@export var popup_close_sound: AudioStream
@export var hover_sound: AudioStream
@export var stamp_sound: AudioStream
@export var ink_sound: AudioStream

# Audio players pool for overlapping sounds
var audio_players: Array[AudioStreamPlayer] = []
const POOL_SIZE = 8

func _ready():
	# Create audio player pool
	for i in POOL_SIZE:
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		audio_players.append(player)
	
	# Connect to EventBus signals
	EventBus.sfx_click.connect(_on_click)
	EventBus.sfx_drag_start.connect(_on_drag_start)
	EventBus.sfx_drag_end.connect(_on_drag_end)
	EventBus.sfx_drop_success.connect(_on_drop_success)
	EventBus.sfx_drop_fail.connect(_on_drop_fail)
	EventBus.sfx_popup_open.connect(_on_popup_open)
	EventBus.sfx_popup_close.connect(_on_popup_close)
	EventBus.sfx_hover.connect(_on_hover)
	EventBus.sfx_stamp.connect(_on_stamp)
	EventBus.sfx_ink.connect(_on_ink)

func _get_available_player() -> AudioStreamPlayer:
	for player in audio_players:
		if not player.playing:
			return player
	return audio_players[0]

func _play_sound(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0):
	if stream == null:
		return
	var player = _get_available_player()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()

# Signal handlers
func _on_click(): _play_sound(click_sound)
func _on_drag_start(): _play_sound(drag_start_sound)
func _on_drag_end(): _play_sound(drag_end_sound)
func _on_drop_success(): _play_sound(drop_success_sound)
func _on_drop_fail(): _play_sound(drop_fail_sound)
func _on_popup_open(): _play_sound(popup_open_sound)
func _on_popup_close(): _play_sound(popup_close_sound)
func _on_hover(): _play_sound(hover_sound)
func _on_stamp(): _play_sound(stamp_sound)
func _on_ink(): _play_sound(ink_sound)

# Public method for custom sounds
func play_custom(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0):
	_play_sound(stream, volume_db, pitch_scale)
