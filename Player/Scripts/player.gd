class_name Player
extends CharacterBody2D

# ------------------------------
# SINAIS
signal health_changed(new_health: float)
signal power_changed(new_power: float)

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
func _ready() -> void:
	state_machine.init()
	sprite.flip_h = (facing_direction == -1)
	collision_layer = 1
	collision_mask = 3
	add_to_group("fighters")
	print("✅ Player pronto")

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	update_facing_based_on_velocity()
	prevent_overlap_with_enemy()
	
	# Aplica dano se estiver atacando
	if is_attacking():
		apply_attack_damage(10)  # 10 de dano como exemplo

func _input(event: InputEvent) -> void:
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
			damage_applied_this_attack = false  # reset para próximo ataque
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
# DANO
func take_damage(damage: int) -> void:
	if is_blocking():
		print("🛡️ Bloqueou o ataque!")
		return

	life = clamp(life - damage, 0, 100)
	emit_signal("health_changed", life)
	print("💥 Player recebeu", damage, "de dano! Vida atual:", life)
	
	if life <= 0:
		print("💀 Player derrotado!")

func gain_power(amount: float) -> void:
	power = clamp(power + amount, 0, 100)
	emit_signal("power_changed", power)
	print("⚡ Player ganhou", amount, "de poder! Poder atual:", power)

func is_vulnerable() -> bool:
	return not is_attacking() and not is_blocking()

# ------------------------------
# APLICA DANO AOS INIMIGOS
func apply_attack_damage(damage: int):
	if not is_attacking() or damage_applied_this_attack:
		return
	if not body_area:
		return
	for body in body_area.get_overlapping_bodies():
		if body.is_in_group("fighters") and body != self:
			print("💥 Player acertou:", body.name)
			body.take_damage(damage)
			damage_applied_this_attack = true

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
