extends TileMap


var fnl := FastNoiseLite.new()

func _ready() -> void:
	randomize()
	fnl.seed = randi()
	fnl.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	generateMap()

func generateMap() -> void:
	for x in 300:
		for y in 150:
			var noiseVal := fnl.get_noise_2d(x,y)
			if noiseVal < 0.14:
				set_cell(0, Vector2i(x,y), 0, Vector2(61,12))
			else:
				set_cell(0, Vector2i(x,y), 0, Vector2(158,12))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()
