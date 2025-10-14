class_name PlayerSpecialState
extends PlayerState

@export var special_projectile: PackedScene
@export var special_offset: Vector2 = Vector2(20, -10)

# Controle de cooldown e limite
@export var max_specials: int = 2
@export var cooldown_time: float = 1.0

var specials_used: int = 0
var on_cooldown: bool = false
var activated: bool = false

func enter() -> void:
	if not player or not special_projectile:
		return
	
	if on_cooldown or specials_used >= max_specials:
		print("⏳ Especial bloqueado! Cooldown ativo ou limite atingido.")
		if player and player.has_method("change_state"):
			player.change_state("Idle")
		return

	# 🔥 MARCA QUE O PLAYER ESTÁ ATACANDO
	player.set_attacking(true)

	# 🎯 DETECTA DIREÇÃO ATUAL DO PLAYER
	var dir: int = player.get_facing_direction()
	
	if dir == 1:
		print("🎯 ESPECIAL PARA DIREITA (player virado para direita)")
	else:
		print("🎯 ESPECIAL PARA ESQUERDA (player virado para esquerda)")

	# Usa um especial
	specials_used += 1

	# Instancia o projétil
	var projectile = special_projectile.instantiate()

	# Calcula posição com offset baseado na direção
	var spawn_position = player.global_position + Vector2(
		special_offset.x * dir,
		special_offset.y
	)
	
	projectile.position = spawn_position

	# Seta a direção do projétil
	if "direction" in projectile:
		projectile.direction = dir
		print("✅ Direção setada no projétil: ", projectile.direction)

	player.get_parent().add_child(projectile)

	print("🔥 Especial lançado! Direção: ", "DIREITA" if dir == 1 else "ESQUERDA", " | Restam:", max_specials - specials_used)

	# Se atingiu o limite, inicia cooldown
	if specials_used >= max_specials:
		start_cooldown()

	activated = true

func exit() -> void:
	# 🔥 MARCA QUE O PLAYER PAROU DE ATACAR
	player.set_attacking(false)
	activated = false

func process_physics(delta: float) -> State:
	if activated:
		activated = false
		return idle_state
	return null

func start_cooldown() -> void:
	if on_cooldown:
		return
	on_cooldown = true
	print("⏳ Iniciando cooldown de ", cooldown_time, " segundos")
	await get_tree().create_timer(cooldown_time).timeout
	specials_used = 0
	on_cooldown = false
	print("✅ Cooldown finalizado, especiais recarregados!")
