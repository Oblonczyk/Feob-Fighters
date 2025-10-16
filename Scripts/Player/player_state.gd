class_name PlayerState
extends State

@onready var player: Player = get_tree().get_first_node_in_group("Player")
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)

# Nomes das animações
var idle_anim := "Idle"
var walk_anim := "Walk"
var jump_anim := "Jump"
var fall_anim := "Fall"
var punch_anim := "Punch"
var kick_anim := "Kick"
var special_anim := "Special"

# Estados (definidos no Editor)
@export_group("States")
@export var idle_state: PlayerState
@export var walk_state: PlayerState
@export var jump_state: PlayerState
@export var fall_state: PlayerState
@export var punch_state: PlayerState
@export var kick_state: PlayerState
@export var special_state: PlayerState

# Ações de input (definidas no Input Map da Godot)
@export_group("Input")
@export var left_key: StringName = "Left"
@export var right_key: StringName = "Right"
@export var movement_key: StringName = "Movement"
@export var jump_key: StringName = "Jump"
@export var punch_key: StringName = "Punch"
@export var kick_key: StringName = "Kick"
@export var special_key: StringName = "Special"

# Controle de flip
var sprite_flipped := false

# Pré-calcula textos dos eventos para flip
var left_actions := InputMap.action_get_events(left_key).map(
	func(a: InputEvent): return a.as_text().get_slice("(", 0)
)
var right_actions := InputMap.action_get_events(right_key).map(
	func(a: InputEvent): return a.as_text().get_slice("(", 0)
)

# Log de inicialização
func _ready():
	print("🟢 Estado inicializado:", name,
		"| Special ligado a:", special_state if special_state else "<null>",
		"| Idle ligado a:", idle_state if idle_state else "<null>"
	)

func determine_sprite_flipped(event_text: String) -> void:
	if left_actions.find(event_text) != -1:
		sprite_flipped = true
	elif right_actions.find(event_text) != -1:
		sprite_flipped = false

	player.sprite.flip_h = sprite_flipped

func process_physics(delta: float) -> State:
	# Movimento básico + gravidade se aplicável nos estados filhos
	player.move_and_slide()
	return null

# Logs detalhados para debug
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(special_key):
		print("⚡ Input detectado:", special_key)
		print("🔎 Estado atual do PlayerState:", name)
		print("   • special_state:", special_state)
		print("   • state_machine:", player.state_machine if player else "🚨 Player não encontrado")
		print("   • specials_used:", special_state.specials_used if special_state else "N/A")
		print("   • max_specials:", special_state.max_specials if special_state else "N/A")
		print("   • on_cooldown:", special_state.on_cooldown if special_state else "N/A")

		if special_state and player and player.state_machine:
			if special_state.on_cooldown or special_state.specials_used >= special_state.max_specials:
				print("⏳ Bloqueado! Cooldown ativo ou limite atingido.")
				if idle_state:
					print("↩️ Retornando para Idle")
					player.state_machine.change_state(idle_state)
				return
			
			print("➡️ Mudando para estado especial:", special_state)
			player.state_machine.change_state(special_state)
		else:
			print("❌ Estado especial ou state_machine não configurados!")
			if not special_state:
				print("🚨 ERRO: special_state não foi atribuído no Inspector (verifique no Editor)!")
			if not player or not player.state_machine:
				print("🚨 ERRO: state_machine não está setado no Player!")
