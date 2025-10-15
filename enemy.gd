extends CharacterBody2D
class_name Enemy

@export var speed: float = 65.0
@export var player_path: NodePath

# NOVAS VARIÁVEIS DE IA
@export var difficulty_level: int = 1
@export var accuracy_percentage: float = 0.7
@export var reaction_time_min: float = 0.2
@export var reaction_time_max: float = 0.5

# NOVAS VARIÁVEIS PARA CICLOS DE COMBATE
@export var max_attacks_per_cycle: int = 2
@export var min_retreat_time: float = 1.5
@export var max_retreat_time: float = 3.0

enum AI_PERSONALITY {AGGRESSIVE, DEFENSIVE, BALANCED, UNPREDICTABLE}
@export var personality: AI_PERSONALITY = AI_PERSONALITY.BALANCED

@onready var state_machine: EnemyStateMachine = $"State Machine"
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

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

# ❤️ VIDA E ⚡ PODER
var life: float = 100.0
var power: float = 0.0
@onready var hud = get_tree().root.get_node_or_null("Level/HUD")

# -----------------------------------------------------------
func _ready() -> void:
	print("Enemy _ready called")
	
	if player_path.is_empty():
		print("ERROR: Player path is empty!")
		return
	
	player = get_node(player_path)
	if not is_instance_valid(player):
		print("ERROR: Player is not valid!")
		return
	
	print("Player found: ", player.name)
	setup_reaction_timer()
	await get_tree().process_frame
	state_machine.init(self)
	
	print("StateMachine initialized successfully")
	print("AI Personality: ", AI_PERSONALITY.keys()[personality])

	update_hud()  # Atualiza HUD no início

# -----------------------------------------------------------
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

# -----------------------------------------------------------
# 🧠 IA - utilitários
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
		_:
			return {"attack_bias": 1.0, "block_bias": 1.0, "move_bias": 1.0}

# -----------------------------------------------------------
# 🔥 EVITA ATRAVESSAR DURANTE ATAQUE
func enable_collision(value: bool) -> void:
	if is_instance_valid(collision_shape):
		collision_shape.disabled = not value

# -----------------------------------------------------------
# ⚔️ ATAQUES
func can_attack() -> bool:
	if not can_attack_flag:
		var current_time = Time.get_unix_time_from_system()
		if current_time - attack_cooldown_timer >= 0.3:
			can_attack_flag = true
			attack_cooldown_timer = 0.0
		else:
			return false
	
	if current_attack_cycle >= max_attacks_per_cycle:
		return false
	
	return randf() <= accuracy_percentage

func record_attack() -> void:
	can_attack_flag = false
	attack_cooldown_timer = Time.get_unix_time_from_system()
	current_attack_cycle += 1
	enable_collision(true)

func reset_attack_cycle() -> void:
	current_attack_cycle = 0
	can_attack_flag = true
	attack_cooldown_timer = 0.0

# -----------------------------------------------------------
# 💥 DANO E PODER
func take_damage(damage: int) -> void:
	if is_blocking:
		var reduced_damage = int(damage * 0.2)
		life = clamp(life - reduced_damage, 0, 100)
		print("🛡️ Enemy bloqueou! Dano reduzido para ", reduced_damage)
	else:
		life = clamp(life - damage, 0, 100)
		print("💥 Enemy tomou ", damage, " de dano! Vida atual: ", life)

	update_hud()

	if life <= 0:
		print("💀 Enemy derrotado!")

func gain_power(amount: float) -> void:
	power = clamp(power + amount, 0, 100)
	print("⚡ Enemy ganhou ", amount, " de poder! Poder atual: ", power)
	update_hud()

func update_hud() -> void:
	if hud:
		hud.set_player2_life(life)
		hud.set_player2_power(power)

# -----------------------------------------------------------
# 🩸 HITBOX
func create_hitbox(damage: int, duration: float) -> void:
	var hitbox = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20.0
	collision.shape = shape
	hitbox.add_child(collision)
	
	var offset = 1
	if sprite.flip_h:
		offset = -1
	hitbox.position = Vector2(30 * offset, 0)
	
	hitbox.collision_mask = 1
	add_child(hitbox)
	
	hitbox.body_entered.connect(_on_hitbox_body_entered.bind(damage))
	
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(hitbox):
		hitbox.queue_free()

func _on_hitbox_body_entered(body: Node, damage: int) -> void:
	if body is Player:
		print("Hit player! Damage: ", damage)
		if body.has_method("take_damage"):
			body.take_damage(damage)

# -----------------------------------------------------------
func get_current_state_name() -> String:
	if state_machine and state_machine.current_state:
		return state_machine.current_state.name
	return "Unknown"

func is_attacking() -> bool:
	if state_machine and state_machine.current_state:
		var name = state_machine.current_state.name
		return "Attack" in name or "Punch" in name or "Kick" in name or "Special" in name
	return false
	
var is_alive: bool = true

func stop_ai():
	set_process(false)
	set_physics_process(false)
