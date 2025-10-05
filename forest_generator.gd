extends Node3D

const CHUNK_SIZE = 50.0
const LOAD_DISTANCE = 6
const UNLOAD_DISTANCE = 8

var tree_scenes = []
var rock_scenes = []
var loaded_chunks = {}
var player: CharacterBody3D

var rng = RandomNumberGenerator.new()


func collision_wrap(glb_scene):
	var static_body = StaticBody3D.new()
	var glb_instance = glb_scene.instantiate()
	var collision = CollisionShape3D.new()
	var mesh_instance = glb_instance.find_child("*", true, false) as MeshInstance3D
	if mesh_instance:
		collision.shape = mesh_instance.mesh.create_trimesh_shape()
	
	static_body.add_child(glb_instance)
	glb_instance.owner = static_body
	static_body.add_child(collision)
	collision.owner = static_body
	var packed_scene = PackedScene.new()
	packed_scene.pack(static_body)
	return packed_scene
	
func _ready():
	player = get_node("../Player")
	
	tree_scenes = [
		collision_wrap(preload("res://nature/tree_default.glb")),
		collision_wrap(preload("res://nature/tree_fat.glb")),
		collision_wrap(preload("res://nature/tree_pineDefaultA.glb")),
		collision_wrap(preload("res://nature/tree_pineGroundB.glb")),
		collision_wrap(preload("res://nature/tree_pineRoundC.glb")),
		collision_wrap(preload("res://nature/tree_pineSmallA.glb")),
		collision_wrap(preload("res://nature/tree_pineTallB.glb"))
	]
	
	rock_scenes = [
		collision_wrap(preload("res://nature/rock_largeA.glb")),
		collision_wrap(preload("res://nature/rock_largeB.glb")),
		collision_wrap(preload("res://nature/rock_largeC.glb")),
		collision_wrap(preload("res://nature/rock_largeD.glb")),
		collision_wrap(preload("res://nature/rock_largeE.glb")),
		collision_wrap(preload("res://nature/rock_largeF.glb")),
		collision_wrap(preload("res://nature/rock_smallA.glb")),
		collision_wrap(preload("res://nature/rock_smallB.glb")),
		collision_wrap(preload("res://nature/rock_smallC.glb")),
		collision_wrap(preload("res://nature/rock_smallD.glb")),
		collision_wrap(preload("res://nature/rock_smallE.glb")),
		collision_wrap(preload("res://nature/rock_smallF.glb")),
		collision_wrap(preload("res://nature/log.glb"))
	]

func _process(_delta):
	if not player:
		return
	
	var player_pos = player.global_position
	var player_chunk = Vector2i(
		int(player_pos.x / CHUNK_SIZE),
		int(player_pos.z / CHUNK_SIZE)
	)
	
	load_chunks_around_player(player_chunk)
	unload_distant_chunks(player_chunk)

func get_chunk_key(chunk_pos: Vector2i) -> String:
	return str(chunk_pos.x) + "," + str(chunk_pos.y)

func load_chunks_around_player(player_chunk: Vector2i):
	for x in range(player_chunk.x - LOAD_DISTANCE, player_chunk.x + LOAD_DISTANCE + 1):
		for z in range(player_chunk.y - LOAD_DISTANCE, player_chunk.y + LOAD_DISTANCE + 1):
			var chunk_pos = Vector2i(x, z)
			var chunk_key = get_chunk_key(chunk_pos)
			
			if not loaded_chunks.has(chunk_key):
				generate_chunk(chunk_pos)

func unload_distant_chunks(player_chunk: Vector2i):
	var chunks_to_remove = []
	
	for chunk_key in loaded_chunks:
		var parts = chunk_key.split(",")
		var chunk_pos = Vector2i(int(parts[0]), int(parts[1]))
		
		var distance = max(abs(chunk_pos.x - player_chunk.x), abs(chunk_pos.y - player_chunk.y))
		
		if distance > UNLOAD_DISTANCE:
			chunks_to_remove.append(chunk_key)
	
	for chunk_key in chunks_to_remove:
		unload_chunk(chunk_key)

func generate_chunk(chunk_pos: Vector2i):
	var chunk_key = get_chunk_key(chunk_pos)
	var chunk_node = Node3D.new()
	chunk_node.name = "Chunk_" + chunk_key
	
	rng.seed = hash(chunk_key)
	
	var world_x = chunk_pos.x * CHUNK_SIZE
	var world_z = chunk_pos.y * CHUNK_SIZE
	
	var tree_count = rng.randi_range(8, 15)
	for i in range(tree_count):
		
		var tree_scene = tree_scenes[rng.randi() % tree_scenes.size()]
		var tree_instance = tree_scene.instantiate()
		
		var x = world_x + rng.randf_range(0, CHUNK_SIZE)
		var z = world_z + rng.randf_range(0, CHUNK_SIZE)
		var y = 0.0
		
		tree_instance.position = Vector3(x, y, z)
		
		var scale = rng.randf_range(8.0, 12.0)
		tree_instance.scale = Vector3(scale, scale, scale)
		
		tree_instance.rotation.y = rng.randf() * TAU
		
		chunk_node.add_child(tree_instance)
	
	var rock_count = rng.randi_range(3, 8)
	for i in range(rock_count):
		var rock_scene = rock_scenes[rng.randi() % rock_scenes.size()]
		var rock_instance = rock_scene.instantiate()
		
		var x = world_x + rng.randf_range(0, CHUNK_SIZE)
		var z = world_z + rng.randf_range(0, CHUNK_SIZE)
		var y = 0.0
		
		rock_instance.position = Vector3(x, y, z)
		
		var scale = rng.randf_range(3.0, 8.0)
		rock_instance.scale = Vector3(scale, scale, scale)
		
		rock_instance.rotation.y = rng.randf() * TAU
		
		chunk_node.add_child(rock_instance)
	
	add_child(chunk_node)
	loaded_chunks[chunk_key] = chunk_node

func unload_chunk(chunk_key: String):
	if loaded_chunks.has(chunk_key):
		var chunk_node = loaded_chunks[chunk_key]
		chunk_node.queue_free()
		loaded_chunks.erase(chunk_key)
