extends Area3D
const GRAVITY = Vector3(0,-1,0)
const UP = Vector3(0,3,0)

@onready var lwing = $ButterflyWing2
@onready var rwing = $ButterflyWing

@export var wing_color : Color = Color("red")

const MAX_DIST_FROM_START = 1
const SPEED = -0.75

var init_pos:Vector3
var flap_tween:Tween
var velocity: Vector3
var low_bound: float 
var flapping: bool = false
var caught:bool = false
var rotate_speed:float = 0

func _ready():
	rotate_speed = deg_to_rad(45 - randf()*90)
	velocity = Vector3()
	init_pos = self.position
	low_bound = init_pos.y - randf() * 1.5
	$ButterflyWing/wing_mesh.material_override.albedo_color = wing_color
	$ButterflyWing2/wing_mesh.material_override.albedo_color  = wing_color

func flap_down():
	flapping = true
	if flap_tween: flap_tween.cancel_free()
	flap_tween = get_tree().create_tween()
	flap_tween.tween_property(lwing,"rotation",Vector3(lwing.rotation.x,lwing.rotation.y,deg_to_rad(220)),0.5)
	flap_tween.set_parallel()
	flap_tween.tween_property(rwing,"rotation",Vector3(rwing.rotation.x,rwing.rotation.y,deg_to_rad(-40)),0.5)
	flap_tween.tween_callback(self.flap_up)

func flap_up():
	flapping = false
	if flap_tween: flap_tween.cancel_free()
	flap_tween = get_tree().create_tween()
	flap_tween.tween_property(lwing,"rotation",Vector3(lwing.rotation.x,lwing.rotation.y,deg_to_rad(140)),0.5)
	flap_tween.set_parallel()
	flap_tween.tween_property(rwing,"rotation",Vector3(rwing.rotation.x,rwing.rotation.y,deg_to_rad(40)),0.5)
	
func _process(delta: float) -> void:
	if caught: return
	self.rotate_y(self.rotate_speed*delta)
	var v = Vector3(self.basis.z.x,0.0,self.basis.z.z).normalized() * SPEED
	v.y = self.velocity.y
	v += GRAVITY * delta
	if !flapping and self.position.y < low_bound:
		self.flap_down()
		v += UP * delta * (0.25 + (1-randf()*0.5))
	self.velocity = v	
	self.position += self.velocity * delta

func catch():
	if self.caught: return false
	print("Butterfly Caught!",self.name)
	self.caught = true
	
