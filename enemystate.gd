class_name EnemyState
extends State

var enemy: Enemy
var state_machine: EnemyStateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_physics(delta: float) -> EnemyState:
	# Mantém a colisão funcionando mesmo parado
	if enemy:
		enemy.move_and_slide()
	return null

func process_frame(delta: float) -> EnemyState:
	return null
