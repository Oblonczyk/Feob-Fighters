class_name Player
extends CharacterBody2D

@onready var state_machine: StateMachine = $"State Machine"
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite

# Variável para controlar a direção do player
var facing_direction: int = 1  # 1 = direita, -1 = esquerda

# 🔥 Controle de ataque e defesa
var is_attacking_flag: bool = false
var is_blocking_flag: bool = false

func _ready() -> void:
	state_machine.init()
	sprite.flip_h = (facing_direction == -1)
	
	# ✅ Garante que o player colide apenas com o cenário (não com o inimigo)
	collision_layer = 1
	collision_mask = 3  # 3 = chão/paredes
	add_to_group("fighters")  # para lógica de empurrão, se quiser
	
	print("✅ Player configurado para colidir apenas com o cenário.")

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	update_facing_based_on_velocity()
	prevent_overlap_with_enemy()  # 👈 evita grudarem lateralmente (opcional)

func _input(event: InputEvent) -> void:
	state_machine.process_input(event)

# 🧭 Direção
func update_facing_based_on_velocity() -> void:
	if velocity.x > 0:
		update_facing_direction(1)
	elif velocity.x < 0:
		update_facing_direction(-1)

func get_facing_direction() -> int:
	return facing_direction

func update_facing_direction(new_direction: int) -> void:
	if new_direction != 0 and new_direction != facing_direction:
		facing_direction = new_direction
		sprite.flip_h = (facing_direction == -1)
		print("🎮 Player mudou direção para: ", "ESQUERDA" if facing_direction == -1 else "DIREITA")

# ⚔️ Ataque
func is_attacking() -> bool:
	if state_machine and state_machine.current_state:
		var state = state_machine.current_state
		var state_name = state.name
		
		var is_attack_state = (
			"Punch" in state_name or 
			"Kick" in state_name or 
			"Special" in state_name or
			"Attack" in state_name
		)
		
		if is_attack_state and not is_attacking_flag:
			print("🎯🎯🎯 PLAYER COMEÇOU A ATACAR! Estado: ", state_name)
		elif not is_attack_state and is_attacking_flag:
			print("🎯 Player parou de atacar")
		
		is_attacking_flag = is_attack_state
		return is_attack_state
	
	return is_attacking_flag

func set_attacking(value: bool) -> void:
	if value != is_attacking_flag:
		is_attacking_flag = value
		print("🎯 Player attacking set to: ", value)

# 🛡️ Defesa
func is_blocking() -> bool:
	return is_blocking_flag

func set_blocking(value: bool) -> void:
	if value != is_blocking_flag:
		is_blocking_flag = value
		print("🛡️ Player blocking set to: ", value)

# 💥 Dano
func take_damage(damage: int) -> void:
	print("💥 Player tomou ", damage, " de dano!")

func is_vulnerable() -> bool:
	return not is_attacking() and not is_blocking()

func get_current_state_name() -> String:
	if state_machine and state_machine.current_state:
		return state_machine.current_state.name
	return "Unknown"

# 🧱 Evita sobreposição lateral com o inimigo (opcional)
@onready var body_area: Area2D = $BodyArea

func prevent_overlap_with_enemy():
	if not body_area:
		return
	
	for body in body_area.get_overlapping_bodies():
		if body.is_in_group("fighters") and body != self:
			var diff = global_position.x - body.global_position.x
			if abs(diff) < 20:
				global_position.x += sign(diff) * 2
