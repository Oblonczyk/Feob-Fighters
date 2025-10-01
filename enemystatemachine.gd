extends Node2D
class_name EnemyStateMachine

@export var starting_state: EnemyState
@export var idle_state: EnemyState
@export var follow_state: EnemyState
@export var attack_state: EnemyAttackState

var enemy: Enemy
var current_state: EnemyState

func init(_enemy: Enemy) -> void:
	enemy = _enemy
	
	# Inicializa todos os estados
	_init_states()
	
	# Define o estado inicial
	change_state(starting_state)

func _init_states() -> void:
	print("Initializing states...")
	
	var states = get_children().filter(func(child): return child is EnemyState)
	print("Child states found: ", states.size())
	
	# Inicializa estados filhos
	for state in states:
		state.enemy = enemy
		state.state_machine = self
		print("Initialized state: ", state.name)
	
	# Inicializa estados exportados
	if idle_state:
		idle_state.enemy = enemy
		idle_state.state_machine = self
		print("Idle state initialized: ", idle_state)
	else:
		print("ERROR: Idle state is null!")
	
	if follow_state:
		follow_state.enemy = enemy
		follow_state.state_machine = self
		print("Follow state initialized: ", follow_state)
	else:
		print("ERROR: Follow state is null!")
	
	if attack_state:
		attack_state.enemy = enemy
		attack_state.state_machine = self
		print("Attack state initialized")
	else:
		print("ERROR: Attack state is null!")

func process_frame(delta: float) -> void:
	if current_state:
		var new_state: EnemyState = current_state.process_frame(delta)
		if new_state: 
			change_state(new_state)

func process_physics(delta: float) -> void:
	if current_state:
		var new_state: EnemyState = current_state.process_physics(delta)
		if new_state: 
			change_state(new_state)

func change_state(new_state: EnemyState) -> void:
	if current_state == new_state:
		return
	
	if current_state:
		current_state.exit()
	
	current_state = new_state
	
	if current_state:
		current_state.enter()

func _process(delta: float) -> void:
	process_frame(delta)

func _physics_process(delta: float) -> void:
	process_physics(delta)
