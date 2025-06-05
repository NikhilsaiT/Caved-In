extends TileMap


const VIEW_DISTANCE := 1

var fnl := FastNoiseLite.new()

var current_chunk := Vector2(0, 0)
var loaded_chunks := {}
var chunk_data := {}  

func _ready() -> void:
	randomize()
	fnl.seed = randi()
	fnl.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	load_visible_chunks()

func _input(event: InputEvent) -> void:
	var moved := false
	if event.is_action_pressed("select"):
		set_custom_tile(Vector2i(int(get_global_mouse_position().x/8) - 1, int(get_global_mouse_position().y/8) - 1), Vector2(-1, -1))

func set_custom_tile(center_pos: Vector2i, tile_atlas_pos: Vector2 = Vector2(0, 0)):
	var chunk_pos = center_pos

	for dx in range(1, 2):  
		for dy in range(1, 2):
			var pos = center_pos + Vector2i(dx, dy)
			remove_tile(pos)


func generate_chunk(chunk_pos: Vector2):
	if !loaded_chunks.has(chunk_pos):
		if(!chunk_data.has(chunk_pos)):
			var pos = []
			for x in range(Global.CHUNK_SIZE+2):
				for y in range(Global.CHUNK_SIZE+2):
					var world_pos = Vector2i(int(chunk_pos.x * Global.CHUNK_SIZE + x-1), int(chunk_pos.y * Global.CHUNK_SIZE + y-1))
					var noiseVal = fnl.get_noise_2d(world_pos.x,world_pos.y)
					if noiseVal < 0.14:
						pos.append(world_pos)
						set_cell(0, world_pos, 5, Vector2i(0,0))
					else:
						set_cell(0, world_pos, 5, Vector2i(-1,-1))
			for cell in pos:
				set_cell(0, cell, 5, find_tile_look(cell))
			loaded_chunks[chunk_pos] = true
		elif chunk_data.has(chunk_pos):
			var data = chunk_data[chunk_pos]
			for x in range(Global.CHUNK_SIZE):
				for y in range(Global.CHUNK_SIZE):
					var world_pos = Vector2i(int(chunk_pos.x * Global.CHUNK_SIZE + x), int(chunk_pos.y * Global.CHUNK_SIZE + y))
					set_cell(0, world_pos, 5, data[x][y])
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
		var data = []
		for i in Global.CHUNK_SIZE:
			data.append([])
			for i2 in Global.CHUNK_SIZE:
				data[i].append(Vector2i(0,0))
		for dat in data:
			dat.resize(Global.CHUNK_SIZE)
			dat.fill(Vector2i(0,0))
		for x in Global.CHUNK_SIZE:
			for y in Global.CHUNK_SIZE:
				var world_x = int(chunk_pos.x * Global.CHUNK_SIZE + x)
				var world_y = int(chunk_pos.y * Global.CHUNK_SIZE + y)
				data[x][y] = get_cell_atlas_coords(0,Vector2i(world_x,world_y))
				erase_cell(0, Vector2i(world_x, world_y))
		chunk_data[chunk_pos] = data
		loaded_chunks.erase(chunk_pos)
		
func find_tile_look(tilePos: Vector2i) -> Vector2:
	if(get_cell_atlas_coords(0,Vector2i(tilePos.x,tilePos.y))==Vector2i(-1,-1)):
		return Vector2(-1,-1)
	var area = [get_cell_atlas_coords(0,Vector2i(tilePos.x,tilePos.y-1))!=Vector2i(-1,-1),get_cell_atlas_coords(0,Vector2i(tilePos.x-1,tilePos.y))!=Vector2i(-1,-1),get_cell_atlas_coords(0,Vector2i(tilePos.x+1,tilePos.y))!=Vector2i(-1,-1),get_cell_atlas_coords(0,Vector2i(tilePos.x,tilePos.y+1))!=Vector2i(-1,-1)]
	if(area == [false,
		  false,     false,
				false,]):
		return Vector2(0,0)
	if(area == [false,
		  false,     true,
				false,]):
		return Vector2(1,0)
	if(area == [false,
		  true,      true,
				false,]):
		return Vector2(2,0)
	if(area == [false,
		  true,      false,
				false,]):
		return Vector2(3,0)
	if(area == [false,
		  false,     false,
				true,]):
		return Vector2(0,1)
	if(area == [false,
		  false,     true,
				true,]):
		return Vector2(1,1)
	if(area == [false,
		  true,      true,
				true,]):
		return Vector2(2,1)
	if(area == [false,
		  true,      false,
				true,]):
		return Vector2(3,1)
	if(area == [true,
		  false,      false,
				true,]):
		return Vector2(0,2)
	if(area == [true,
		  false,      true,
				true,]):
		return Vector2(1,2)
	if(area == [true,
		  true,      true,
				true,]):
		return Vector2(2,2)
	if(area == [true,
		  true,      false,
				true,]):
		return Vector2(3,2)
	if(area == [true,
		  false,     false,
				false,]):
		return Vector2(0,3)
	if(area == [true,
		  false,     true,
				false,]):
		return Vector2(1,3)
	if(area == [true,
		  true,     true,
				false,]):
		return Vector2(2,3)
	if(area == [true,
		  true,     false,
				false,]):
		return Vector2(3,3)
	
	
	return Vector2(0,0)

func remove_tile(tilePos: Vector2i):
	set_cell(0,tilePos,5,Vector2i(-1,-1))
	for x in range(-1,2):
		for y in range(-1,2):
			if(!(x==0&&y==0)):
				var newTilePos = tilePos+Vector2i(x,y)
				set_cell(0,newTilePos,5,find_tile_look(newTilePos))
