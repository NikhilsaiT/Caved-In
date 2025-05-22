extends TileMap

const CHUNK_SIZE := 32
const VIEW_DISTANCE := 1


var fnl := FastNoiseLite.new()


var current_chunk := Vector2(0, 0)
var loaded_chunks := {}

func _ready() -> void:
	randomize()
	fnl.seed = randi()
	fnl.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	load_visible_chunks()


func _input(event: InputEvent) -> void:
	var moved := false
	if event.is_action_pressed("right"):
		current_chunk.x += 1
		moved = true
	elif event.is_action_pressed("left"):
		current_chunk.x -= 1
		moved = true
	elif event.is_action_pressed("down"):
		current_chunk.y += 1
		moved = true
	elif event.is_action_pressed("up"):
		current_chunk.y -= 1
		moved = true
	elif event.is_action_pressed("reset"):
		get_tree().reload_current_scene()

	if moved:
		unload_far_chunks()
		load_visible_chunks()


func generate_chunk(chunk_pos: Vector2):
	if loaded_chunks.has(chunk_pos):
		return 

	for x in CHUNK_SIZE:
		for y in CHUNK_SIZE:
			var world_x = int(chunk_pos.x * CHUNK_SIZE + x)
			var world_y = int(chunk_pos.y * CHUNK_SIZE + y)
			var noiseVal = fnl.get_noise_2d(world_x, world_y)
			var tile = Vector2(61, 12) if noiseVal < 0.14 else Vector2(158, 12)
			set_cell(0, Vector2i(world_x, world_y), 0, tile)

	loaded_chunks[chunk_pos] = true


func load_visible_chunks():
	for dx in range(-VIEW_DISTANCE, VIEW_DISTANCE + 1):
		for dy in range(-VIEW_DISTANCE, VIEW_DISTANCE + 1):
			var chunk_pos = current_chunk + Vector2(dx, dy)
			generate_chunk(chunk_pos)


func unload_far_chunks():
	var chunks_to_unload := []
	for chunk_pos in loaded_chunks.keys():
		if abs(chunk_pos.x - current_chunk.x) > VIEW_DISTANCE or abs(chunk_pos.y - current_chunk.y) > VIEW_DISTANCE:
			chunks_to_unload.append(chunk_pos)

	for chunk_pos in chunks_to_unload:
		for x in CHUNK_SIZE:
			for y in CHUNK_SIZE:
				var world_x = int(chunk_pos.x * CHUNK_SIZE + x)
				var world_y = int(chunk_pos.y * CHUNK_SIZE + y)
				erase_cell(0, Vector2i(world_x, world_y))
		loaded_chunks.erase(chunk_pos)
