class_name Player
extends CharacterBody2D

@onready var state_machine: StateMachine = $"State Machine"
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite

# Variável para controlar a direção do player
var facing_direction: int = 1  # 1 = direita, -1 = esquerda

# 🔥 NOVAS VARIÁVEIS PARA CONTROLE DE ATAQUE/DEFESA
var is_attacking_flag: bool = false
var is_blocking_flag: bool = false

func _ready() -> void:
	state_machine.init()
	sprite.flip_h = (facing_direction == -1)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	update_facing_based_on_velocity()

func _input(event: InputEvent) -> void:
	state_machine.process_input(event)

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

# 🔥🔥🔥 MÉTODO is_attacking CORRIGIDO - USA O NOME DO NÓ
func is_attacking() -> bool:
	if state_machine and state_machine.current_state:
		var state = state_machine.current_state
		var state_name = state.name  # 🔥 AGORA USA O NOME DO NÓ!
		
		# DEBUG SIMPLES
		print("🔍 Estado atual: '", state_name, "'")
		
		# Verifica se o nome do nó indica que é um ataque
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

func is_blocking() -> bool:
	return is_blocking_flag

func set_attacking(value: bool) -> void:
	if value != is_attacking_flag:
		is_attacking_flag = value
		print("🎯 Player attacking set to: ", value)

func set_blocking(value: bool) -> void:
	if value != is_blocking_flag:
		is_blocking_flag = value
		print("🛡️ Player blocking set to: ", value)

# 🔥🔥🔥 MÉTODO take_damage SEM KNOCKBACK
func take_damage(damage: int) -> void:
	print("💥 Player tomou ", damage, " de dano!")

func is_vulnerable() -> bool:
	return not is_attacking() and not is_blocking()

func get_current_state_name() -> String:
	if state_machine and state_machine.current_state:
		return state_machine.current_state.name  # 🔥 Também usa o nome aqui
	return "Unknown"
