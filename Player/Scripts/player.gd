class_name Player
extends CharacterBody2D

@onready var state_machine: StateMachine = $"State Machine"
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite

# Função chamada quando o nó e todos os seus filhos estão prontos
func _ready() -> void:
	state_machine.init()

# Função chamada a cada quadro, processando a lógica do jogo (não física)
func _process(delta: float) -> void:
	state_machine.process_frame(delta)

# Função chamada a cada quadro de física, ideal para movimento
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

# Função para lidar com eventos de entrada (teclado, mouse, etc.)
func _input(event: InputEvent) -> void:
	state_machine.process_input(event)
