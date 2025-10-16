class_name Camera
extends Camera2D

const INIT_ZOOM: Vector2 = Vector2.ONE * 4 
const INIT_OFFSET: Vector2 = Vector2.ZERO

var cur_zoom: Vector2 = INIT_ZOOM
var cur_offset: Vector2 = INIT_OFFSET

var shake_recov_fac: float = 1.0
var zoom_recov_fac: float = 1.0

func _ready() -> void:
	zoom = INIT_ZOOM
	offset = INIT_OFFSET

func _process(delta: float) -> void:
	recover_zoom(delta)

func recover_zoom(delta: float) -> void:
	cur_zoom = lerp(cur_zoom, INIT_ZOOM, delta * zoom_recov_fac)
	zoom = cur_zoom

func set_zoom_str(zoom_str: float) -> void:
	cur_zoom *= zoom_str
