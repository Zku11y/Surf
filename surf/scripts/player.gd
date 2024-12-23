extends CharacterBody3D

@onready var head: Node3D = $head
@export var speed := 50.0
@export var sprint_speed := 10.0
const walking_speed := 5.0
const jump_velocity := 5
const mouse_sens := 0.1
var lerp_speed := 9.0
const friction_offset := 0
var sprinting := false
@export var acel := 1.5
var acel_vect := Vector3.ZERO
@export var friction_rate := 30
var direction := Vector3.ZERO
var input_dir := Vector2.ZERO
var look_dir := Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	look_dir = head.get_global_transform().basis.z.normalized()
	look_dir.y = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * mouse_sens)
		head.rotate_x(deg_to_rad(-event.relative.y) * mouse_sens)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-70), deg_to_rad(70))


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	
	if not is_on_floor():
	
		#velocity += get_gravity() * delta
		velocity = velocity.move_toward(Vector3(0, -1000, 0), delta * 10)

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("left", "right", "front", "back")
	direction = lerp(direction, (head.get_global_transform().basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), lerp_speed * delta)
	sprinting = Input.is_action_pressed("sprint")
	#print(sprinting)
	if input_dir != Vector2.ZERO:
		print("acceleration!!!   value = ", velocity)
		if sprinting:
			if is_on_floor() && abs(velocity.x) >= 20:
				if velocity.x > 0:
					velocity.x -= 1
				else:
					velocity.x += 1
			accelerate(direction * sprint_speed, delta)
		else:
			if is_on_floor() && abs(velocity.x) >= 20:
				if velocity.x > 0:
					velocity.x -= 1
				else:
					velocity.x += 1
			accelerate(direction, delta)
			#print(velocity)
			#velocity.x = direction.x * speed
			#velocity.z = direction.z * speed
	else:
		if is_on_floor():
			friction(0.5, delta)
			print("friction!!!!")
		#velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
func accelerate(input_dir : Vector3, delta):
	velocity = velocity.move_toward(input_dir * speed, acel * delta * 50)
	#print("velocity forward = ", velocity.y)

func friction(friction_offset, delta):
	velocity = velocity.move_toward(Vector3.ZERO, friction_rate * delta)
	#func friction
