extends Node3D

@export var butterfly_scene: PackedScene = preload("res://butterfly.tscn")
@export var max_butterflies = 100
@export var spawn_radius = 30.0
@export var despawn_radius = 50.0
@export var min_spawn_height = 2.0
@export var max_spawn_height = 8.0

var butterflies = []
var player: CharacterBody3D
var rng = RandomNumberGenerator.new()

var wing_colors = [
	Color(0.65341854, 0.3907194, 0.863884, 1),
	Color(0.18809971, 0.8247265, 0.5407835, 1),
	Color(0.08447579, 0.34111455, 0.7493064, 1),
	Color(1, 0.92986554, 0.63943905, 1),
	Color(0.54384506, 0.7948984, 0.711413, 1),
	Color(0.9, 0.2, 0.3, 1),
	Color(0.2, 0.9, 0.4, 1),
	Color(0.3, 0.5, 0.9, 1),
	Color(0.8, 0.6, 0.2, 1),
	Color(0.6, 0.3, 0.8, 1)
]

func _ready():
	player = get_node("../Player")
	rng.randomize()

func _process(_delta):
	if not player:
		return
	
	cleanup_distant_butterflies()
	spawn_butterflies_if_needed()

func cleanup_distant_butterflies():
	for i in range(butterflies.size() - 1, -1, -1):
		var butterfly = butterflies[i]
		if not is_instance_valid(butterfly):
			butterflies.remove_at(i)
			continue
		
		var distance = butterfly.global_position.distance_to(player.global_position)
		if distance > despawn_radius:
			butterfly.queue_free()
			butterflies.remove_at(i)

func spawn_butterflies_if_needed():
	while butterflies.size() < max_butterflies:
		spawn_butterfly()

func spawn_butterfly():
	var butterfly = butterfly_scene.instantiate()
	
	var angle = rng.randf() * TAU
	var distance = rng.randf_range(10.0, spawn_radius)
	
	var spawn_pos = player.global_position + Vector3(
		cos(angle) * distance,
		rng.randf_range(min_spawn_height, max_spawn_height),
		sin(angle) * distance
	)
	
	butterfly.global_position = spawn_pos
	
	var color = wing_colors[rng.randi() % wing_colors.size()]
	butterfly.wing_color = color
	
	add_child(butterfly)
	butterflies.append(butterfly)
