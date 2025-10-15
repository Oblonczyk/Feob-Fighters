extends CanvasLayer

# Caminhos para os jogadores
@export var player1_path: NodePath
@export var player2_path: NodePath

# Barras
@onready var p1_life_bar = $Player1UI/LifeBar
@onready var p1_power_bar = $Player1UI/PowerBar
@onready var p2_life_bar = $Player2UI/LifeBar
@onready var p2_power_bar = $Player2UI/PowerBar

var player1
var player2


func _ready():
	# Pega referências dos jogadores
	player1 = get_node(player1_path)
	player2 = get_node(player2_path)
	
	# Conecta sinais de vida e poder
	player1.connect("health_changed", Callable(self, "set_player1_life"))
	player1.connect("power_changed", Callable(self, "set_player1_power"))
	player2.connect("health_changed", Callable(self, "set_player2_life"))
	player2.connect("power_changed", Callable(self, "set_player2_power"))

	# Inicializa barras
	set_player1_life(player1.life)
	set_player1_power(player1.power)
	set_player2_life(player2.life)
	set_player2_power(player2.power)


func set_player1_life(value: float):
	p1_life_bar.value = clamp(value, 0, 100)

func set_player1_power(value: float):
	p1_power_bar.value = clamp(value, 0, 100)

func set_player2_life(value: float):
	p2_life_bar.value = clamp(value, 0, 100)

func set_player2_power(value: float):
	p2_power_bar.value = clamp(value, 0, 100)
