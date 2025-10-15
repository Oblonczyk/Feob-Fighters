class_name EnemyFollowState
extends EnemyState

var jump_cooldown: float = 2.0
var last_jump_time: float = 0.0
var last_decision_time: float = 0.0
var decision_cooldown: float = 2.0
var current_behavior: String = "approach"
var raycast_front: RayCast2D
var attacks_in_current_approach: int = 0
var max_attacks_before_retreat: int = 2
var behavior_stick_time: float = 0.0
var last_attack_check_time: float = 0.0
var circle_time: float = 0.0

func enter() -> void:
	print("Enemy Following - AGGRESSIVE MODE")
	play_walk_animation()
	reset_attack_counters()
	make_decision()
	behavior_stick_time = 2.0
	last_attack_check_time = Time.get_unix_time_from_system()
	circle_time = 0.0
	
	# Raycast para obstáculos
	raycast_front = RayCast2D.new()
	raycast_front.enabled = true
	raycast_front.collision_mask = 1
	raycast_front.target_position = Vector2(50 * (-1 if enemy.sprite.flip_h else 1), 0)
	enemy.add_child(raycast_front)

func exit() -> void:
	if raycast_front and is_instance_valid(raycast_front):
		raycast_front.queue_free()

func reset_attack_counters() -> void:
	attacks_in_current_approach = 0
	if enemy.has_method("reset_attack_cycle"):
		enemy.reset_attack_cycle()
	print("🔥 Attack counters reset - Ready for new approach")

func play_walk_animation() -> void:
	if enemy.animation != null and enemy.animation.has_animation("Walk"):
		enemy.animation.play("Walk")
	elif enemy.sprite != null and enemy.sprite.sprite_frames != null and enemy.sprite.sprite_frames.has_animation("Walk"):
		enemy.sprite.play("Walk")

func make_decision() -> void:
	var weights = get_decision_weights()
	var random_choice = randf()
	var cumulative_weight = 0.0
	
	for behavior in weights.keys():
		cumulative_weight += weights[behavior]
		if random_choice <= cumulative_weight:
			current_behavior = behavior
			break
	
	print("AI Decision: ", current_behavior, " - Attacks: ", attacks_in_current_approach, "/", max_attacks_before_retreat)
	last_decision_time = Time.get_unix_time_from_system()
	behavior_stick_time = 2.0
	circle_time = 0.0

func get_decision_weights() -> Dictionary:
	var weights = {
		"approach": 0.0,
		"circle": 0.0,
		"retreat": 0.0
	}
	
	var distance = enemy.distance_to_player()
	var player_attacking = enemy.player_is_attacking()
	
	if attacks_in_current_approach >= max_attacks_before_retreat:
		weights["retreat"] = 0.9
		weights["circle"] = 0.1
		weights["approach"] = 0.0
		print("Max attacks reached, forcing retreat")
	elif current_behavior == "circle" and circle_time > 3.0:
		weights["approach"] = 0.8
		weights["circle"] = 0.2
		weights["retreat"] = 0.0
		print("Circling for too long, forcing approach")
	elif distance < 80.0:
		weights["approach"] = 0.8
		weights["circle"] = 0.15
		weights["retreat"] = 0.05
	elif distance < 150.0:
		weights["approach"] = 0.9
		weights["circle"] = 0.08
		weights["retreat"] = 0.02
	else:
		weights["approach"] = 0.95
		weights["circle"] = 0.05
		weights["retreat"] = 0.0
	
	if player_attacking:
		weights["retreat"] += 0.1
		weights["circle"] += 0.05
	
	var total = weights["approach"] + weights["circle"] + weights["retreat"]
	if total > 0:
		weights["approach"] /= total
		weights["circle"] /= total
		weights["retreat"] /= total
	
	return weights

func process_physics(delta: float) -> EnemyState:
	var player_pos = enemy.player.global_position
	var enemy_pos = enemy.global_position
	var distance = enemy_pos.distance_to(player_pos)
	var current_time = Time.get_unix_time_from_system()
	
	# 🔥🔥🔥 CORREÇÃO CRÍTICA: VERIFICAÇÃO DE DEFESA
	var should_defend = false
	
	if enemy.has_method("is_player_attacking_nearby") and enemy.has_method("can_block"):
		var is_player_attacking = enemy.is_player_attacking_nearby()
		var can_block_now = enemy.can_block()
		
		if is_player_attacking:
			print("🎯 PLAYER ATACANDO! Distância: ", distance)
			print("🔍 Verificando defesa... CanBlock: ", can_block_now)
			
			if can_block_now:
				print("🛡️ CONDIÇÕES DE DEFESA ATENDIDAS!")
				should_defend = true
			else:
				print("❌ Defesa bloqueada - Razões:")
				if enemy.is_blocking:
					print("   - Já está defendendo")
				var time_since_last_block = current_time - enemy.block_cooldown
				if time_since_last_block < 1.0:
					print("   - Em cooldown: ", time_since_last_block, "s")
				print("   - Chance falhou ou outras condições")
	
	# 🔥 SE DEVE DEFENDER, MUDA PARA DEF STATE
	if should_defend and state_machine.def_state:
		print("🛡️🛡️🛡️ MUDANDO PARA DEF STATE!")
		return state_machine.def_state
	elif should_defend and not state_machine.def_state:
		print("❌❌❌ ERRO CRÍTICO: Def state é NULL!")
		print("💡 Configure a propriedade 'Def State' no Inspector do Enemy")
	
	# ATUALIZA TEMPO DE COMPORTAMENTO
	behavior_stick_time -= delta
	
	# ATUALIZA TEMPO DE CÍRCULO
	if current_behavior == "circle":
		circle_time += delta
	else:
		circle_time = 0.0
	
	# RESET AUTOMÁTICO
	if attacks_in_current_approach > 0 and current_time - last_decision_time > 5.0:
		reset_attack_counters()
		make_decision()
		print("🔄 Auto-reset due to inactivity")
	
	# REAVALIA DECISÃO
	if behavior_stick_time <= 0 and current_time - last_decision_time > decision_cooldown:
		make_decision()
	
	# VERIFICAÇÃO DE ATAQUE
	if current_time - last_attack_check_time > 0.5:
		last_attack_check_time = current_time
		
		if distance < 80.0 and attacks_in_current_approach < max_attacks_before_retreat:
			if enemy.can_attack():
				print("⚔️ ATTACK! Distance: ", distance, " Attacks: ", attacks_in_current_approach + 1, "/", max_attacks_before_retreat)
				attacks_in_current_approach += 1
				return state_machine.attack_state
			else:
				print("🔍 Can't attack - Conditions not met")
	
	# ATUALIZA RAYCAST
	var direction_to_player = (player_pos - enemy_pos).normalized()
	if raycast_front:
		raycast_front.target_position = Vector2(50 * (-1 if direction_to_player.x < 0 else 1), 0)
	
	# VELOCIDADE CONSTANTE
	var move_speed = enemy.get_movement_speed()
	
	# COMPORTAMENTOS
	match current_behavior:
		"approach":
			enemy.velocity.x = direction_to_player.x * move_speed
		"circle":
			var perpendicular = Vector2(-direction_to_player.y, direction_to_player.x) * 0.3
			enemy.velocity.x = (direction_to_player.x * 0.6 + perpendicular.x * 0.4) * move_speed
		"retreat":
			enemy.velocity.x = -direction_to_player.x * move_speed * 1.5
			if distance > 100.0:
				reset_attack_counters()
				make_decision()
	
	# SISTEMA DE PULO
	if enemy.is_on_floor() and current_time - last_jump_time > jump_cooldown:
		if raycast_front and raycast_front.is_colliding():
			print("Jumping over obstacle")
			last_jump_time = current_time
			return state_machine.jump_state
	
	# FÍSICA
	if not enemy.is_on_floor():
		enemy.velocity.y += 980.0 * delta
	else:
		enemy.velocity.y = 0
	
	enemy.move_and_slide()

	# FLIP SPRITE
	if direction_to_player.x != 0:
		enemy.sprite.flip_h = direction_to_player.x < 0
	
	return null
