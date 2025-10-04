extends CharacterBody3D

const GRAVITY = Vector3(0,-0.1,0)
const UP = Vector3(0,0.3,0)

@onready var lwing = $ButterflyWing2
@onready var rwing = $ButterflyWing

@export var wing_color : Color = Color("red")

var flap_tween:Tween

func _ready():
	$ButterflyWing/wing_mesh.material_override.albedo_color = wing_color
	$ButterflyWing2/wing_mesh.material_override.albedo_color  = wing_color

func flap_down():
	if flap_tween: flap_tween.cancel_free()
	flap_tween = get_tree().create_tween()
	flap_tween.tween_property(lwing,"rotation",Vector3(lwing.rotation.x,lwing.rotation.y,deg_to_rad(220)),0.25)
	flap_tween.set_parallel()
	flap_tween.tween_property(rwing,"rotation",Vector3(rwing.rotation.x,rwing.rotation.y,deg_to_rad(-40)),0.25)
	flap_tween.tween_callback(self.flap_up)

func flap_up():
	if flap_tween: flap_tween.cancel_free()
	flap_tween = get_tree().create_tween()
	flap_tween.tween_property(lwing,"rotation",Vector3(lwing.rotation.x,lwing.rotation.y,deg_to_rad(140)),0.25)
	flap_tween.set_parallel()
	flap_tween.tween_property(rwing,"rotation",Vector3(rwing.rotation.x,rwing.rotation.y,deg_to_rad(40)),0.25)
	
func _process(delta: float) -> void:
	var v = self.velocity
	var dir = Vector3(v.x,0,v.y)
	v += GRAVITY * delta
	if self.position.y <= 3:
		self.flap_down()
		v += UP * delta * (0.25 + (1-randf()*0.5))
	self.velocity = v
	dir.rotated(Vector3(0,1,0),deg_to_rad(2))
	self.velocity = Vector3(dir.x,v.y,dir.z)
	self.move_and_collide(self.velocity)
