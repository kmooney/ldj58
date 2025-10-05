extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.005
const SPEED = 8.0
const JUMP_VELOCITY = 5.5
const BOB_AMP = 0.3
const BOB_FREQ = 3.76
var bob_time = 0.0
var speed = SPEED

@onready var camera = $Camera3D

func _ready():
	floor_max_angle = deg_to_rad(70)
	floor_snap_length = 0.5
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if Input.is_action_just_pressed('ui_activate'):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_pressed('running'):
		speed = SPEED + SPEED * 0.33
	else:
		speed = SPEED

	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
			
	move_and_slide()
	
	if is_on_floor() and velocity.length() > 0.1:
		bob_time += delta * velocity.length() * 0.5
		camera.position.y = 0.6 + sin(bob_time * BOB_FREQ) * BOB_AMP
	else:
		bob_time = 0.0
		camera.position.y = lerp(camera.position.y, 0.6, delta * 10.0)
