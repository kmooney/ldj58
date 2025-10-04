extends Node3D

var start_net_rot:Vector3
var swiping:bool
var swipe_ready:bool

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var net_plane: Plane
var caught_bug: Node3D

func _ready():
	start_net_rot = $NetArm.rotation
	swiping = false
	swipe_ready = true
	net_plane = Plane(Vector3(0,1,0),$NetArm/Net.global_position)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and swipe_ready:
			swipe()
		elif event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				
func swipe():
	swiping = true
	swipe_ready = false
	var tween = get_tree().create_tween()
	tween.tween_property($NetArm,"rotation",Vector3(deg_to_rad(-90),0,0),0.15)
	tween.tween_callback(self.finish_swipe)
	
func finish_swipe():
	var tween = get_tree().create_tween()
	tween.tween_property($NetArm,"rotation",start_net_rot,0.5)
	tween.tween_callback(self.reset_swipe)
	swiping = false
	if caught_bug:
		caught_bug.queue_free()
		caught_bug = null
	
func reset_swipe():
	swipe_ready = true
			
func _on_net_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if swiping:
		area.catch()
		caught_bug = area
	
func _process(delta:float):
	var mouse_pos:Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_normal: Vector3 = camera.project_ray_normal(mouse_pos)
	var intersection = net_plane.intersects_ray(ray_origin,ray_normal)
	if intersection:
		$NetArm.position.x = intersection.x
		$NetArm.position.z = intersection.z
	if caught_bug:
		caught_bug.global_position = $NetArm/Net/Ring.global_position
