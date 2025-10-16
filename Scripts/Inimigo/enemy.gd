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
var block_cooldown: float = 1.0
var block_duration: float = 3.0
var block_start_time: float = 0.0

# ❤️ VIDA E ⚡ PODER
var life: float = 100.0
var power: float = 0.0
@onready var hud = get_tree().root.get_node_or_null("Level/HUD")

# ------------------------------
# KNOCKBACK
var is_knockback_active: bool = false
var knockback_timer: float = 0.0
var knockback_duration: float = 0.25
var knockback_force: float = 250.0
var knockback_direction: int = 0

# ------------------------------
# 🔥 SISTEMA DE MORTE
var is_alive: bool = true
var death_animation_played: bool = false

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

	update_hud()  # Atualiza HUD no início

# -----------------------------------------------------------
func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	if is_knockback_active:
		handle_knockback(delta)
		return

	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	if not is_alive:
		return
	state_machine.process_frame(delta)

# -----------------------------------------------------------
# 🧠 IA - utilitários
func distance_to_player() -> float:
	if not is_instance_valid(player) or not is_alive:
		return INF
	return global_position.distance_to(player.global_position)

func direction_to_player() -> Vector2:
	if not is_instance_valid(player) or not is_alive:
		return Vector2.ZERO
	return (player.global_position - global_position).normalized()

func get_movement_speed() -> float:
	return speed

func setup_reaction_timer() -> void:
	reaction_timer = Timer.new()
	reaction_timer.one_shot = true
	add_child(reaction_timer)

func can_react_to_player() -> bool:
	return can_react and is_instance_valid(player) and is_alive

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
# 🧠 SISTEMA DE PADRÕES DO PLAYER E ESTRATÉGIAS
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

# -----------------------------------------------------------
# 🔥 EVITA ATRAVESSAR DURANTE ATAQUE
func enable_collision(value: bool) -> void:
	if is_instance_valid(collision_shape):
		collision_shape.disabled = not value

# -----------------------------------------------------------
# ⚔️ ATAQUES
func can_attack() -> bool:
	if not is_alive or not can_attack_flag:
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
	enable_collision(true)
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

# -----------------------------------------------------------
# 🛡️ SISTEMA DE DEFESA CORRIGIDO
func can_block() -> bool:
	if not is_alive or is_blocking:
		print("❌ can_block: Já está bloqueando ou morto")
		return false

	var current_time = Time.get_unix_time_from_system()
	if current_time - block_cooldown < 1.0:
		print("❌ can_block: Em cooldown - ", current_time - block_cooldown, "s")
		return false

	var block_chance = 0.9
	match personality:
		AI_PERSONALITY.DEFENSIVE:
			block_chance = 0.7
		AI_PERSONALITY.AGGRESSIVE:
			block_chance = 0.2

	var success = randf() < block_chance
	print("🎲 can_block: Chance ", block_chance * 100, "% | Resultado: ", success)
	return success

func start_block() -> void:
	var block_attempt_time = Time.get_ticks_msec() / 1000.0  # em segundos
	print("🛡️ [DEBUG] Tentando bloquear em:", block_attempt_time)
	
	if not can_block():
		print("🚫 start_block cancelado — não pode bloquear agora")
		return

	is_blocking = true
	block_start_time = Time.get_unix_time_from_system()
	
	if animation and animation.has_animation("block"):
		animation.play("block")
		print("🎬 Animação de block iniciada - DEFESA ATIVA")
	
	print("🛡️ Enemy started blocking - 80% damage reduction ACTIVE")

func end_block() -> void:
	if is_blocking:  # Só executa se realmente estava bloqueando
		is_blocking = false
		block_cooldown = Time.get_unix_time_from_system()
		
		if animation and animation.has_animation("idle"):
			animation.play("idle")
		
		print("🛡️ Enemy stopped blocking - 80% damage reduction INACTIVE")

func is_player_attacking_nearby() -> bool:
	if not is_instance_valid(player) or not is_alive:
		print("❌ is_player_attacking_nearby: Player não é válido ou enemy morto")
		return false
	
	var distance = distance_to_player()
	if distance > 150.0:
		return false
	
	if player.has_method("is_attacking"):
		return player.is_attacking()
	else:
		print("❌ is_player_attacking_nearby: Player não tem método is_attacking")
	
	return false

# -----------------------------------------------------------
# 💥 DANO E MORTE
func take_damage(damage: int, from_position: Vector2 = Vector2.ZERO) -> void:
	if not is_alive:
		return
	
	var damage_receive_time = Time.get_ticks_msec() / 1000.0
	print("===============================")
	print("🧪 [DEBUG] Dano recebido em:", damage_receive_time)
	print("🧪 [DEBUG] is_blocking no impacto: ", is_blocking)
	var final_damage = damage
	
	if is_blocking:
		var damage_reduction = 0.8
		final_damage = int(damage * (1.0 - damage_reduction))
		life = clamp(life - final_damage, 0, 100)
		print("🛡️ Enemy bloqueou! Dano reduzido em 80%: de ", damage, " para ", final_damage)
	else:
		final_damage = damage
		life = clamp(life - final_damage, 0, 100)
		print("💥 Enemy tomou ", final_damage, " de dano! Vida atual: ", life)

	record_player_action("player_attack", true)
	update_hud()

	# Aplica knockback apenas se não estiver bloqueando
	if not is_blocking:
		if from_position != Vector2.ZERO:
			knockback_direction = sign(global_position.x - from_position.x)
			if knockback_direction == 0:
				knockback_direction = 1 if sprite.flip_h else -1
		else:
			knockback_direction = 1 if sprite.flip_h else -1
		
		start_knockback()
		print("💢 Knockback FORÇADO - direção:", knockback_direction)

	if not is_in_retreat and randf() < 0.6:
		start_retreat()

	# 🔥 VERIFICA SE MORREU
	if life <= 0:
		die()

func die() -> void:
	if not is_alive:
		return
	
	print("💀 ENEMY MORREU!")
	is_alive = false
	
	# 🔥 PARA TODOS OS MOVIMENTOS
	velocity = Vector2.ZERO
	is_knockback_active = false
	
	# 🔥 TOCA ANIMAÇÃO DE MORTE
	play_death_animation()
	
	# 🔥 DESATIVA COLISÕES E FÍSICA
	set_physics_process(false)
	set_process(false)
	collision_layer = 0
	collision_mask = 0
	
	# 🔥 PARA A IA
	stop_ai()
	
	# 🔥 OPÇÃO: REMOVER DA CENA APÓS ALGUM TEMPO
	# await get_tree().create_timer(3.0).timeout
	# queue_free()

func play_death_animation() -> void:
	if death_animation_played:
		return
	
	death_animation_played = true
	
	# 🔥 TENTA TOCAR ANIMAÇÃO DE MORTE
	if animation and animation.has_animation("death"):
		animation.play("death")
		print("🎬 Tocando animação de morte do Enemy")
	elif animation and animation.has_animation("dead"):
		animation.play("dead")
		print("🎬 Tocando animação 'dead' do Enemy")
	elif sprite and sprite.sprite_frames:
		if sprite.sprite_frames.has_animation("death"):
			sprite.play("death")
			print("🎬 Tocando animação de morte no sprite")
		elif sprite.sprite_frames.has_animation("dead"):
			sprite.play("dead")
			print("🎬 Tocando animação 'dead' no sprite")
		else:
			# 🔥 FALLBACK: Para animação atual
			sprite.stop()
			print("🎬 Parando animação - Enemy morto")
	else:
		print("❌ Nenhuma animação de morte encontrada")

func start_knockback() -> void:
	is_knockback_active = true
	knockback_timer = knockback_duration
	velocity.x = knockback_force * knockback_direction
	velocity.y = -80
	print("💢 Enemy knockback ativado - Força: ", knockback_force, " Direção: ", knockback_direction)

func handle_knockback(delta: float) -> void:
	knockback_timer -= delta
	
	velocity.x = lerp(velocity.x, 0.0, delta * 6.0)
	velocity.y += 400.0 * delta
	
	move_and_slide()
	
	if knockback_timer <= 0:
		is_knockback_active = false
		velocity = Vector2.ZERO
		print("✅ Enemy knockback finalizado")

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
	if not is_alive:
		return
		
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
	
	if not hitbox.body_entered.is_connected(_on_hitbox_body_entered):
		hitbox.body_entered.connect(_on_hitbox_body_entered.bind(damage))
	
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(hitbox):
		hitbox.queue_free()

func _on_hitbox_body_entered(body: Node, damage: int) -> void:
	if not is_alive:
		return
		
	if body is Player:
		print("💥 Enemy acertou player! Damage: ", damage)
		record_player_action("attack", true)
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position)
	else:
		record_player_action("attack", false)

# -----------------------------------------------------------
# 📊 DEBUG E UTILITÁRIOS
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
	return not is_in_retreat and current_attack_cycle < max_attacks_per_cycle and is_alive

func is_attacking() -> bool:
	if not is_alive:
		return false
		
	if state_machine and state_machine.current_state:
		var name = state_machine.current_state.name
		return "Attack" in name or "Punch" in name or "Kick" in name or "Special" in name
	return false

func stop_ai():
	set_process(false)
	set_physics_process(false)
