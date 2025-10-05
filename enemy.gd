extends CharacterBody2D
class_name Enemy

@export var speed: float = 75.0
@export var player_path: NodePath

# NOVAS VARIÁVEIS DE IA
@export var difficulty_level: int = 1
@export var accuracy_percentage: float = 0.7
@export var reaction_time_min: float = 0.2
@export var reaction_time_max: float = 0.5

# NOVAS VARIÁVEIS PARA SISTEMA DE CICLOS DE COMBATE
@export var max_attacks_per_cycle: int = 2
@export var min_retreat_time: float = 1.5
@export var max_retreat_time: float = 3.0

enum AI_PERSONALITY {AGGRESSIVE, DEFENSIVE, BALANCED, UNPREDICTABLE}
@export var personality: AI_PERSONALITY = AI_PERSONALITY.BALANCED

@onready var state_machine: EnemyStateMachine = $"State Machine"
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite

var player: Player
var player_patterns: Dictionary = {}
var successful_actions: Dictionary = {}
var reaction_timer: Timer
var can_react: bool = true

# SISTEMA DE ATAQUE
var current_attack_cycle: int = 0
var is_in_retreat: bool = false
var attack_cooldown_timer: float = 0.0
var can_attack_flag: bool = true

# VARIÁVEIS PARA DEFESA
@export var def_state: EnemyDefState
var is_blocking: bool = false
var block_cooldown: float = 0.0
var block_duration: float = 1.5
var block_start_time: float = 0.0

func _ready() -> void:
	print("Enemy _ready called")
	
	# Pega o player a partir do NodePath exportado
	if player_path.is_empty():
		print("ERROR: Player path is empty!")
		return
	
	player = get_node(player_path)
	
	if not is_instance_valid(player):
		print("ERROR: Player is not valid!")
		return
	
	print("Player found: ", player.name)
	
	# Configura timer de reação
	setup_reaction_timer()
	
	# Aguarda até o próximo frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	state_machine.init(self)
	
	# 🔥 VERIFICAÇÃO DO DEF STATE
	print("=== VERIFICAÇÃO DO DEF STATE ===")
	print("Def State configurado?: ", state_machine.def_state != null)
	if state_machine.def_state:
		print("✅ Def State: ", state_machine.def_state.name)
	else:
		print("❌ ERRO: Def State NÃO configurado!")
		print("💡 Arraste o nó EnemyDefState para a propriedade 'Def State' no Inspector")
	print("=================================")
	
	print("StateMachine initialized successfully")
	print("AI Personality: ", AI_PERSONALITY.keys()[personality])
	print("Difficulty Level: ", difficulty_level)
	print("Accuracy: ", accuracy_percentage * 100, "%")
	print("Max attacks per cycle: ", max_attacks_per_cycle)
	print("Speed: ", speed)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func distance_to_player() -> float:
	if not is_instance_valid(player):
		return INF
	return global_position.distance_to(player.global_position)

func direction_to_player() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.ZERO
	return (player.global_position - global_position).normalized()

func get_movement_speed() -> float:
	return speed

# NOVAS FUNÇÕES DE IA
func setup_reaction_timer() -> void:
	reaction_timer = Timer.new()
	reaction_timer.one_shot = true
	add_child(reaction_timer)

func can_react_to_player() -> bool:
	return can_react and is_instance_valid(player)

func start_reaction_cooldown() -> void:
	can_react = false
	var reaction_time = randf_range(reaction_time_min, reaction_time_max)
	reaction_timer.start(reaction_time)
	await reaction_timer.timeout
	can_react = true

func player_is_attacking() -> bool:
	if player and player.has_method("is_attacking"):
		return player.is_attacking()
	return false

func get_personality_modifiers() -> Dictionary:
	match personality:
		AI_PERSONALITY.AGGRESSIVE:
			return {"attack_bias": 1.5, "block_bias": 0.5, "move_bias": 0.8}
		AI_PERSONALITY.DEFENSIVE:
			return {"attack_bias": 0.7, "block_bias": 1.5, "move_bias": 1.2}
		AI_PERSONALITY.UNPREDICTABLE:
			return {"attack_bias": randf_range(0.5, 2.0), "block_bias": randf_range(0.5, 2.0), "move_bias": randf_range(0.5, 2.0)}
		_: # BALANCED
			return {"attack_bias": 1.0, "block_bias": 1.0, "move_bias": 1.0}

func record_player_action(action: String, successful: bool) -> void:
	if not player_patterns.has(action):
		player_patterns[action] = {"count": 0, "successful": 0}
	
	player_patterns[action]["count"] += 1
	if successful:
		player_patterns[action]["successful"] += 1
	
	print("Recorded player action: ", action, " Successful: ", successful)

func get_counter_strategy() -> String:
	var most_used_attack = ""
	var highest_count = 0
	
	for action in player_patterns:
		if player_patterns[action]["count"] > highest_count:
			highest_count = player_patterns[action]["count"]
			most_used_attack = action
	
	match most_used_attack:
		"punch": 
			return "block"
		"kick": 
			return "jump"
		"jump": 
			return "attack"
		_: 
			return "block"

func get_ai_decision() -> String:
	var base_decision = get_counter_strategy()
	var modifiers = get_personality_modifiers()
	
	if base_decision == "attack" and randf() < modifiers["attack_bias"] - 1.0:
		return "attack"
	elif base_decision == "block" and randf() < modifiers["block_bias"] - 1.0:
		return "block"
	
	return base_decision

# SISTEMA DE ATAQUE
func can_attack() -> bool:
	if not can_attack_flag:
		var current_time = Time.get_unix_time_from_system()
		if current_time - attack_cooldown_timer >= 0.3:
			can_attack_flag = true
			attack_cooldown_timer = 0.0
		else:
			print("🔍 Can't attack - Cooldown active")
			return false
	
	if current_attack_cycle >= max_attacks_per_cycle:
		print("🔍 Can't attack - Max attacks in cycle reached: ", current_attack_cycle, "/", max_attacks_per_cycle)
		return false
	
	var accuracy_check = randf() <= accuracy_percentage
	print("🔍 Accuracy check: ", accuracy_check, " (", accuracy_percentage * 100, "% chance)")
	return accuracy_check

func record_attack() -> void:
	can_attack_flag = false
	attack_cooldown_timer = Time.get_unix_time_from_system()
	current_attack_cycle += 1
	print("⚔️ Attack recorded. Cycle: ", current_attack_cycle, "/", max_attacks_per_cycle)
	
	if current_attack_cycle >= max_attacks_per_cycle:
		print("🛡️ Max attacks in cycle reached, will retreat soon")

func reset_attack_cycle() -> void:
	current_attack_cycle = 0
	can_attack_flag = true
	attack_cooldown_timer = 0.0
	print("🔥 Attack cycle reset - Ready for new attacks!")

func reset_attack_cycle_if_needed() -> void:
	if current_attack_cycle >= max_attacks_per_cycle:
		var current_time = Time.get_unix_time_from_system()
		if current_time - attack_cooldown_timer > 2.0:
			reset_attack_cycle()
			print("🔄 Auto-reset attack cycle")

func start_retreat() -> void:
	is_in_retreat = true
	print("Starting retreat")

func end_retreat() -> void:
	is_in_retreat = false
	reset_attack_cycle()
	print("Retreat ended, attack cycle reset")

# FUNÇÕES PARA DEFESA
func can_block() -> bool:
	if is_blocking:
		print("❌ can_block: Já está bloqueando")
		return false
	
	var current_time = Time.get_unix_time_from_system()
	if current_time - block_cooldown < 1.0:
		print("❌ can_block: Em cooldown - ", current_time - block_cooldown, "s")
		return false
	
	var block_chance = 0.3
	match personality:
		AI_PERSONALITY.DEFENSIVE:
			block_chance = 0.7
		AI_PERSONALITY.AGGRESSIVE:
			block_chance = 0.2
	
	var success = randf() < block_chance
	print("🎲 can_block: Chance ", block_chance * 100, "% | Resultado: ", success)
	return success

func start_block() -> void:
	is_blocking = true
	block_start_time = Time.get_unix_time_from_system()
	print("🛡️ Enemy started blocking")

func end_block() -> void:
	is_blocking = false
	block_cooldown = Time.get_unix_time_from_system()
	print("🛡️ Enemy stopped blocking")

func is_player_attacking_nearby() -> bool:
	if not is_instance_valid(player):
		print("❌ is_player_attacking_nearby: Player não é válido")
		return false
	
	var distance = distance_to_player()
	if distance > 150.0:
		return false
	
	if player.has_method("is_attacking"):
		var is_attacking = player.is_attacking()
		return is_attacking
	else:
		print("❌ is_player_attacking_nearby: Player não tem método is_attacking")
	
	return false

# FUNÇÃO take_damage SEM KNOCKBACK
func take_damage(damage: int) -> void:
	if is_blocking:
		var reduced_damage = int(damage * 0.2)
		print("🛡️ Blocked attack! Reduced damage from ", damage, " to ", reduced_damage)
	else:
		print("Enemy took ", damage, " damage!")
	
	record_player_action("player_attack", true)
	
	if not is_in_retreat and randf() < 0.6:
		start_retreat()

# SISTEMA DE HITBOX SEM KNOCKBACK
func create_hitbox(damage: int, duration: float) -> void:
	var hitbox = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	
	shape.radius = 20.0
	collision.shape = shape
	hitbox.add_child(collision)
	
	hitbox.position = Vector2(30 * (-1 if sprite.flip_h else 1), 0)
	hitbox.collision_mask = 1
	
	add_child(hitbox)
	
	if not hitbox.body_entered.is_connected(_on_hitbox_body_entered):
		hitbox.body_entered.connect(_on_hitbox_body_entered.bind(damage))
	
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(hitbox):
		hitbox.queue_free()

func _on_hitbox_body_entered(body: Node, damage: int) -> void:
	if body is Player:
		print("Hit player! Damage: ", damage)
		record_player_action("attack", true)
		if body.has_method("take_damage"):
			body.take_damage(damage)
	else:
		record_player_action("attack", false)

func print_ai_stats() -> void:
	print("=== AI STATISTICS ===")
	print("Personality: ", AI_PERSONALITY.keys()[personality])
	print("Difficulty: ", difficulty_level)
	print("Accuracy: ", accuracy_percentage * 100, "%")
	print("Current Attack Cycle: ", current_attack_cycle, "/", max_attacks_per_cycle)
	print("Is in Retreat: ", is_in_retreat)
	print("Is Blocking: ", is_blocking)
	print("Speed: ", speed)
	print("Player Patterns: ", player_patterns)
	print("====================")

func get_current_state_name() -> String:
	if state_machine and state_machine.current_state:
		return state_machine.current_state.name
	return "Unknown"

func is_ready_for_action() -> bool:
	return not is_in_retreat and current_attack_cycle < max_attacks_per_cycle
