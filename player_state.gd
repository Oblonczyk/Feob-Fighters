class_name PlayerState
extends State

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var camera: Camera = get_tree().get_first_node_in_group("Camera")

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)

# Nomes das animações
var idle_anim := "Idle"
var walk_anim := "Walk"
var jump_anim := "Jump"
var fall_anim := "Fall"
var punch_anim := "Punch"
var kick_anim := "Kick"

# Estados
@export_group("States")
@export var idle_state: PlayerState
@export var walk_state: PlayerState
@export var jump_state: PlayerState
@export var fall_state: PlayerState
@export var punch_state: PlayerState
@export var kick_state: PlayerState

# Ações de input
@export_group("Input")
@export var left_key: StringName = "Left"
@export var right_key: StringName = "Right"
@export var movement_key: StringName = "Movement"
@export var jump_key: StringName = "Jump"
@export var punch_key: StringName = "Punch"
@export var kick_key: StringName = "Kick"

var sprite_flipped := false

# Pré-calcula textos dos eventos para flip (opcional)
var left_actions := InputMap.action_get_events(left_key).map(func(a:InputEvent):
	return a.as_text().get_slice("(", 0))
var right_actions := InputMap.action_get_events(right_key).map(func(a:InputEvent):
	return a.as_text().get_slice("(", 0))
	
func determine_sprite_flipped(event_text: String) -> void:
	if left_actions.find(event_text) != -1:
		sprite_flipped = true
	elif right_actions.find(event_text) != -1:
		sprite_flipped = false
		
	player.sprite.flip_h = sprite_flipped
	
func process_physics(delta: float) -> State:
	# ⚠️ A gravidade deve ser aplicada nos estados específicos (Idle, Jump, Fall)
	# então aqui só garantimos o movimento.
	player.move_and_slide()
	return null
