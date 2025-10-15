extends Node2D
class_name EnemyStateMachine

@export var starting_state: EnemyState
@export var idle_state: EnemyState
@export var follow_state: EnemyState
@export var attack_state: EnemyAttackState
@export var def_state: EnemyDefState
@export var jump_state: EnemyJumpState
@export var fall_state: EnemyFallState

var enemy: Enemy
var current_state: EnemyState

func init(_enemy: Enemy) -> void:
	enemy = _enemy
	_init_states()
	change_state(starting_state)

func _init_states() -> void:
	var states = get_children().filter(func(child): return child is EnemyState)
	for state in states:
		state.enemy = enemy
		state.state_machine = self

	# Inicializa estados exportados
	if idle_state: idle_state.enemy = enemy; idle_state.state_machine = self
	if follow_state: follow_state.enemy = enemy; follow_state.state_machine = self
	if attack_state: attack_state.enemy = enemy; attack_state.state_machine = self
	if def_state: def_state.enemy = enemy; def_state.state_machine = self
	if jump_state: jump_state.enemy = enemy; jump_state.state_machine = self
	if fall_state: fall_state.enemy = enemy; fall_state.state_machine = self

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
	if current_state == new_state: return
	if current_state: current_state.exit()
	current_state = new_state
	if current_state: current_state.enter()

func _process(delta: float) -> void:
	process_frame(delta)

func _physics_process(delta: float) -> void:
	process_physics(delta)
	
