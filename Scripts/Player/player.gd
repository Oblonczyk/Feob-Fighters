class_name Player
extends CharacterBody2D

# ------------------------------
# SINAIS
signal health_changed(new_health: float)
signal power_changed(new_power: float)
signal died()  # 🔥 NOVO SINAL: Player morreu

# ------------------------------
# NODES
@onready var state_machine: StateMachine = $"State Machine"
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var body_area: Area2D = $BodyArea

# ------------------------------
# DIREÇÃO
var facing_direction: int = 1  # 1 = direita, -1 = esquerda

# ------------------------------
# ATAQUE/DEFESA
var is_attacking_flag: bool = false
var is_blocking_flag: bool = false
var damage_applied_this_attack: bool = false  # evita múltiplos hits por ataque

# ------------------------------
# VIDA / PODER
var life: float = 100
var power: float = 0

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
var is_falling_after_death: bool = false

# ------------------------------
func _ready() -> void:
	state_machine.init()
	sprite.flip_h = (facing_direction == -1)
	collision_layer = 1
	collision_mask = 3
	add_to_group("fighters")
	print("✅ Player pronto")

func _process(delta: float) -> void:
	if not is_alive:
		return
	state_machine.process_frame(delta)

func _physics_process(delta: float) -> void:
	if not is_alive:
		# 🔥 CORREÇÃO: Continua física mesmo morto para cair do mapa
		if is_falling_after_death:
			handle_death_fall(delta)
		return
	
	if is_knockback_active:
		handle_knockback(delta)
		return

	state_machine.process_physics(delta)
	update_facing_based_on_velocity()
	prevent_overlap_with_enemy()
	
	if is_attacking():
		apply_attack_damage(10)

func _input(event: InputEvent) -> void:
	if not is_alive or is_knockback_active:
		return
	state_machine.process_input(event)

# ------------------------------
# DIREÇÃO
func update_facing_based_on_velocity() -> void:
	if velocity.x > 0:
		update_facing_direction(1)
	elif velocity.x < 0:
		update_facing_direction(-1)

func update_facing_direction(new_direction: int) -> void:
	if new_direction != 0 and new_direction != facing_direction:
		facing_direction = new_direction
		sprite.flip_h = (facing_direction == -1)
		print("🎮 Player virou:", "ESQUERDA" if facing_direction == -1 else "DIREITA")

func get_facing_direction() -> int:
	return facing_direction

# ------------------------------
# ATAQUE
func is_attacking() -> bool:
	if not is_alive:
		return false
		
	if state_machine and state_machine.current_state:
		var state_name = state_machine.current_state.name
		var attacking = "Punch" in state_name or "Kick" in state_name or "Special" in state_name or "Attack" in state_name
		if attacking and not is_attacking_flag:
			print("🎯 PLAYER ATACANDO!")
		elif not attacking and is_attacking_flag:
			print("🎯 PLAYER PAROU DE ATACAR")
		is_attacking_flag = attacking
		return attacking
	return is_attacking_flag

func set_attacking(value: bool) -> void:
	if value != is_attacking_flag:
		is_attacking_flag = value
		if not value:
			damage_applied_this_attack = false
		print("🎯 attacking set to:", value)

# ------------------------------
# DEFESA
func is_blocking() -> bool:
	return is_blocking_flag

func set_blocking(value: bool) -> void:
	if value != is_blocking_flag:
		is_blocking_flag = value
		print("🛡️ blocking set to:", value)

# ------------------------------
# DANO E MORTE
func take_damage(damage: int, from_position: Vector2 = Vector2.ZERO) -> void:
	if not is_alive or is_blocking():
		print("🛡️ Bloqueou o ataque ou já está morto!")
		return

	life = clamp(life - damage, 0, 100)
	emit_signal("health_changed", life)
	print("💥 Player recebeu", damage, "de dano! Vida atual:", life)

	if from_position != Vector2.ZERO:
		knockback_direction = sign(global_position.x - from_position.x)
		if knockback_direction == 0:
			knockback_direction = 1
		start_knockback()

	# 🔥 VERIFICA SE MORREU
	if life <= 0:
		die()

func die() -> void:
	if not is_alive:
		return
	
	print("💀 PLAYER MORREU!")
	is_alive = false
	is_falling_after_death = true  # 🔥 ATIVA QUEDA APÓS MORTE
	
	# 🔥 EMITE SINAL DE MORTE
	emit_signal("died")
	
	# 🔥 PARA MOVIMENTOS CONTROLADOS, MAS MANTÉM FÍSICA PARA QUEDA
	velocity = Vector2.ZERO
	is_knockback_active = false
	
	# 🔥 TOCA ANIMAÇÃO DE MORTE
	play_death_animation()
	
	# 🔥 DESATIVA COLISÕES MAS MANTÉM FÍSICA PARA QUEDA
	collision_layer = 0
	collision_mask = 0
	
	# 🔥 INICIA QUEDA
	start_death_fall()
	
	# 🔥 REMOVE DA CENA APÓS CAIR FORA DA TELA
	start_despawn_timer()

func play_death_animation() -> void:
	if death_animation_played:
		return
	
	death_animation_played = true
	
	# 🔥 TENTA TOCAR ANIMAÇÃO DE MORTE
	if animation and animation.has_animation("death"):
		animation.play("death")
		print("🎬 Tocando animação de morte do Player")
	elif animation and animation.has_animation("dead"):
		animation.play("dead")
		print("🎬 Tocando animação 'dead' do Player")
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
			print("🎬 Parando animação - Player morto")
	else:
		print("❌ Nenhuma animação de morte encontrada")

# ------------------------------
# 🔥 SISTEMA DE QUEDA APÓS MORTE
func start_death_fall() -> void:
	print("🌪️ Player iniciando queda após morte...")
	# 🔥 Aplica uma pequena força inicial para baixo e aleatória
	velocity.y = 100  # Começa caindo
	velocity.x = randf_range(-50, 50)  # Pequeno movimento lateral aleatório

func handle_death_fall(delta: float) -> void:
	# 🔥 APLICA GRAVIDADE CONTINUAMENTE
	velocity.y += 400.0 * delta  # Gravidade
	
	# 🔥 MOVIMENTO LATERAL SUAVE DURANTE QUEDA
	velocity.x = lerp(velocity.x, 0.0, delta * 2.0)
	
	move_and_slide()
	
	# 🔥 VERIFICA SE CAIU FORA DA TELA
	if global_position.y > get_viewport_rect().size.y + 100:
		print("📉 Player caiu fora da tela, removendo...")
		queue_free()

func start_despawn_timer() -> void:
	# 🔥 REMOVE AUTOMATICAMENTE APÓS 5 SEGUNDOS (SEGURANÇA)
	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(self):
		print("⏰ Timer de remoção do Player ativado")
		queue_free()

func start_knockback() -> void:
	is_knockback_active = true
	knockback_timer = knockback_duration
	velocity.x = knockback_force * knockback_direction
	velocity.y = -50
	print("💢 Knockback ativado direção:", knockback_direction)

func handle_knockback(delta: float) -> void:
	knockback_timer -= delta
	
	# Aplica desaceleração suave
	velocity.x = lerp(velocity.x, 0.0, delta * 8.0)
	velocity.y += 400.0 * delta  # Gravidade
	
	move_and_slide()
	
	if knockback_timer <= 0:
		is_knockback_active = false
		velocity = Vector2.ZERO
		print("✅ Knockback finalizado")

func gain_power(amount: float) -> void:
	power = clamp(power + amount, 0, 100)
	emit_signal("power_changed", power)
	print("⚡ Player ganhou", amount, "de poder! Poder atual:", power)

func is_vulnerable() -> bool:
	return not is_attacking() and not is_blocking() and is_alive

# ------------------------------
# APLICA DANO AOS INIMIGOS
func apply_attack_damage(damage: int):
	if not is_alive or not is_attacking() or damage_applied_this_attack:
		return
	if not body_area:
		return
		
	for body in body_area.get_overlapping_bodies():
		if body.is_in_group("fighters") and body != self:
			print("💥 Player acertou:", body.name)
			if body.has_method("take_damage"):
				# Passa a posição do player para calcular direção do knockback
				body.take_damage(damage, global_position)
			damage_applied_this_attack = true
			break  # Aplica dano apenas no primeiro inimigo acertado

# ------------------------------
# EVITA SOBREPOSIÇÃO LATERAL
func prevent_overlap_with_enemy():
	if not body_area:
		return
	for body in body_area.get_overlapping_bodies():
		if body.is_in_group("fighters") and body != self:
			var diff = global_position.x - body.global_position.x
			if abs(diff) < 20:
				global_position.x += sign(diff) * 2

# ------------------------------
# 🔥 FUNÇÃO PARA REINICIAR (OPCIONAL)
func respawn(new_position: Vector2) -> void:
	is_alive = true
	is_falling_after_death = false
	death_animation_played = false
	life = 100
	power = 0
	global_position = new_position
	
	# 🔥 REATIVA TUDO
	set_physics_process(true)
	set_process(true)
	collision_layer = 1
	collision_mask = 3
	
	# 🔥 VOLTA PARA ANIMAÇÃO NORMAL
	if animation and animation.has_animation("idle"):
		animation.play("idle")
	elif sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	
	print("🔄 Player respawned!")
