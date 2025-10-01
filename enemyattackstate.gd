class_name EnemyAttackState
extends EnemyState

# Configuração dos ataques
@export var attack_combos: Array[Array] = [
	["Punch", "Punch", "Punch"],
	["Punch", "Punch", "Kick"], 
	["Punch", "Kick", "Punch"],
	["Kick", "Punch", "Punch"],
	["Kick", "Kick", "Punch"],
	["Punch", "Kick", "Kick"],
	["Kick", "Punch", "Kick"],
	["Kick", "Kick", "Kick"]
]

# TEMPOS SEPARADOS PARA CADA ATAQUE
@export var punch_delay_ms: int = 1000    # 1 segundo para soco
@export var kick_delay_ms: int = 3000     # 3 segundos para chute
@export var combo_cooldown_ms: int = 5000 # 5 segundos entre combos

var current_combo: Array = []
var current_attack_index: int = 0
var attack_timer: float = 0.0
var is_attacking: bool = false
var current_attack_type: String = ""
var start_time: float = 0.0

func enter() -> void:
	print("Enemy Attack State - ENTER")
	start_time = Time.get_ticks_msec()
	enemy.velocity = Vector2.ZERO
	select_random_combo()
	start_next_attack()

func exit() -> void:
	var total_time = Time.get_ticks_msec() - start_time
	print("Enemy Attack State - EXIT (Total time: ", total_time, "ms)")
	current_combo.clear()
	current_attack_index = 0
	attack_timer = 0.0
	is_attacking = false
	current_attack_type = ""
	play_idle_animation()

func select_random_combo() -> void:
	var random_index = randi() % attack_combos.size()
	current_combo = attack_combos[random_index].duplicate()
	current_attack_index = 0
	print("Starting combo: ", current_combo, " at ", Time.get_ticks_msec() - start_time, "ms")

func start_next_attack() -> void:
	if current_attack_index >= current_combo.size():
		attack_timer = combo_cooldown_ms / 1000.0
		current_attack_index = 0
		print("Combo complete, cooldown started at ", Time.get_ticks_msec() - start_time, "ms")
		play_idle_animation()
		return
	
	current_attack_type = current_combo[current_attack_index]
	is_attacking = true
	
	# DEFINE O TEMPO CORRETO PARA CADA TIPO DE ATAQUE
	match current_attack_type:
		"Punch":
			attack_timer = punch_delay_ms / 1000.0
			print("Punch timer set: ", punch_delay_ms, "ms at ", Time.get_ticks_msec() - start_time, "ms")
		"Kick":
			attack_timer = kick_delay_ms / 1000.0
			print("Kick timer set: ", kick_delay_ms, "ms at ", Time.get_ticks_msec() - start_time, "ms")
	
	execute_attack(current_attack_type)
	current_attack_index += 1

func execute_attack(attack_type: String) -> void:
	var attack_start_time = Time.get_ticks_msec()
	print("Executing: ", attack_type, " at ", attack_start_time - start_time, "ms")
	
	match attack_type:
		"Punch":
			play_punch_animation()
			apply_punch_damage()
			print("Waiting punch delay: ", punch_delay_ms, "ms")
			# CORREÇÃO: Não usar await aqui, o timer já é controlado por attack_timer
		"Kick":
			play_kick_animation()
			apply_kick_damage()
			print("Waiting kick delay: ", kick_delay_ms, "ms")
			# CORREÇÃO: Não usar await aqui
	
	# REMOVA os awaits - o timing é controlado por attack_timer no process_physics
	print("Attack ", attack_type, " execution started at ", Time.get_ticks_msec() - start_time, "ms")

func play_idle_animation() -> void:
	var idle_time = Time.get_ticks_msec()
	if enemy and enemy.animation and enemy.animation.has_animation("Idle"):
		enemy.animation.play("Idle")
		print("Playing Idle animation at ", idle_time - start_time, "ms")
	elif enemy and enemy.sprite and enemy.sprite.sprite_frames and enemy.sprite.sprite_frames.has_animation("Idle"):
		enemy.sprite.play("Idle")
		print("Playing Idle animation on sprite at ", idle_time - start_time, "ms")

func play_punch_animation() -> void:
	var punch_time = Time.get_ticks_msec()
	if enemy and enemy.animation and enemy.animation.has_animation("Punch"):
		enemy.animation.play("Punch")
		print("Playing Punch animation at ", punch_time - start_time, "ms")
	elif enemy and enemy.sprite and enemy.sprite.sprite_frames and enemy.sprite.sprite_frames.has_animation("Punch"):
		enemy.sprite.play("Punch")
		print("Playing Punch animation on sprite at ", punch_time - start_time, "ms")

func play_kick_animation() -> void:
	var kick_time = Time.get_ticks_msec()
	if enemy and enemy.animation and enemy.animation.has_animation("Kick"):
		enemy.animation.play("Kick")
		print("Playing Kick animation at ", kick_time - start_time, "ms")
	elif enemy and enemy.sprite and enemy.sprite.sprite_frames and enemy.sprite.sprite_frames.has_animation("Kick"):
		enemy.sprite.play("Kick")
		print("Playing Kick animation on sprite at ", kick_time - start_time, "ms")

func apply_punch_damage() -> void:
	var damage_time = Time.get_ticks_msec()
	if enemy and enemy.has_method("create_hitbox"):
		enemy.create_hitbox(10, 50, 0.2)
		print("Punch damage applied at ", damage_time - start_time, "ms")

func apply_kick_damage() -> void:
	var damage_time = Time.get_ticks_msec()
	if enemy and enemy.has_method("create_hitbox"):
		enemy.create_hitbox(15, 70, 0.3)
		print("Kick damage applied at ", damage_time - start_time, "ms")

func process_physics(delta: float) -> EnemyState:
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			if is_attacking:
				is_attacking = false
				print("Attack timer finished at ", Time.get_ticks_msec() - start_time, "ms")
				# VOLTA PARA IDLE ANTES DO PRÓXIMO ATAQUE
				play_idle_animation()
				start_next_attack()
			else:
				print("Cooldown timer finished at ", Time.get_ticks_msec() - start_time, "ms")
				start_next_attack()
	
	# Verifica se player saiu do range de ataque
	if enemy and is_instance_valid(enemy.player):
		var distance = enemy.global_position.distance_to(enemy.player.global_position)
		if distance > 100.0:
			print("Player out of attack range at ", Time.get_ticks_msec() - start_time, "ms, returning to Follow")
			return state_machine.follow_state
	
	return null
