class_name EnemyState
extends State

# ADICIONE TYPE HINT EXPLÍCITO aqui
var enemy: Enemy
var state_machine: EnemyStateMachine

func process_physics(delta: float) -> EnemyState:
	return null

func process_frame(delta: float) -> EnemyState:
	return null

func enter() -> void:
	pass

func exit() -> void:
	pass
