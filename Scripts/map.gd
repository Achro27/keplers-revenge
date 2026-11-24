extends Node2D

var entity_pre: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity_pre = preload("res://Scenes/entity.tscn")
	
	#save_map_local("user://custom_map.json")
	load_map(get_map_data_local("user://custom_map.json"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_map_local(save_path: String) -> void:
	#Get data from current map
	#Probably moving to seperate scene called "lvl editor" or smth
	var map: Dictionary = {
		"terrain" : [],
		"entities" : []
		}
	
	for cell in $Terrain.get_used_cells():
		#Vector2i is not good for JSON conversion
		#Makes an array of tiles with each tile having an x, y, and atlas_y (block id) value
		map["terrain"].append([cell.x, cell.y, $Terrain.get_cell_atlas_coords(cell).y])
	
	for entity in $Entities.get_children():
		map["entities"].append([entity.position.x, entity.position.y]) #ADD ID SYSTEM
	
	#Save that data locally
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(map))
		file.close()
		print("map saved to " + save_path)
	else:
		print(save_path + " not found")

func get_map_data_local(load_path: String) -> Variant:
	#Extract the data
	var file = FileAccess.open(load_path, FileAccess.READ)
	if not file:
		print("file not found")
		return
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error != OK:
		print("an error occured while parsing the json file")
		return
	
	return json.data

func load_map(map_data) -> void:
	#Terrain
	$Terrain.clear()
	for tile in map_data["terrain"]:
		var coords = Vector2i(tile[0], tile[1])
		var block_id = tile[2]
		
		$Terrain.set_cell(coords, 1, Vector2i(0, block_id))
	
	#Entities (fix id system later)
	for child in $Entities.get_children():
		child.queue_free()
	for entity in map_data["entities"]:
		var new_enitity = entity_pre.instantiate()
		new_enitity.position = Vector2i(entity[0], entity[1])
		$Entities.add_child(new_enitity)
