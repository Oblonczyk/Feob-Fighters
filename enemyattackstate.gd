class_name EnemyAttackState
extends EnemyState

@export var attack_combos: Array[Array] = [
	["Punch"],
	["Punch", "Punch"], 
	["Kick"],
	["Punch", "Kick"]
]

@export var punch_delay_ms: int = 600
@export var kick_delay_ms: int = 800

var current_combo: Array = []
var current_attack_index: int = 0
var attack_timer: float = 0.0
var is_attacking: bool = false
var current_attack_type: String = ""
var damage_applied: bool = false

func enter() -> void:
	damage_applied = false
	select_simple_combo()
	start_next_attack()
	enemy.enable_collision(true) # 🔹 colisão ativa

func exit() -> void:
	current_combo.clear()
	current_attack_index = 0
	attack_timer = 0.0
	is_attacking = false
	current_attack_type = ""
	damage_applied = false

func select_simple_combo() -> void:
	var random_index = randi() % attack_combos.size()
	current_combo = attack_combos[random_index].duplicate()
	current_attack_index = 0

func start_next_attack() -> void:
	if current_attack_index >= current_combo.size():
		return
	current_attack_type = current_combo[current_attack_index]
	is_attacking = true
	damage_applied = false

	match current_attack_type:
		"Punch":
			attack_timer = punch_delay_ms / 1000.0
			play_punch_animation()
		"Kick":
			attack_timer = kick_delay_ms / 1000.0
			play_kick_animation()

	current_attack_index += 1

func execute_attack() -> void:
	if damage_applied:
		return
	damage_applied = true

	var distance = enemy.distance_to_player()
	if distance > 100.0:
		return

	match current_attack_type:
		"Punch":
			enemy.create_hitbox(10, 0.2)
		"Kick":
			enemy.create_hitbox(15, 0.3)

func play_punch_animation() -> void:
	if enemy.animation and enemy.animation.has_animation("Punch"):
		enemy.animation.play("Punch")
	elif enemy.sprite and enemy.sprite.sprite_frames and enemy.sprite.sprite_frames.has_animation("Punch"):
		enemy.sprite.play("Punch")

func play_kick_animation() -> void:
	if enemy.animation and enemy.animation.has_animation("Kick"):
		enemy.animation.play("Kick")
	elif enemy.sprite and enemy.sprite.sprite_frames and enemy.sprite.sprite_frames.has_animation("Kick"):
		enemy.sprite.play("Kick")

func process_physics(delta: float) -> EnemyState:
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= (punch_delay_ms / 1000.0) * 0.3 and not damage_applied and is_attacking:
			execute_attack()
		if attack_timer <= 0 and is_attacking:
			is_attacking = false
			start_next_attack()

	# 🔹 Aplica física para manter colisão
	enemy.move_and_slide()

	if not is_attacking and attack_timer <= 0 and current_attack_index >= current_combo.size():
		return state_machine.follow_state
	return null
