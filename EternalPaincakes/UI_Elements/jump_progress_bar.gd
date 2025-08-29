extends TextureProgressBar

var tick_step = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func tick():
	if value == max_value:
		tick_step = -1
	if value == min_value:
		tick_step = +1
	value += tick_step
	
func reset():
	value = min_value
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
