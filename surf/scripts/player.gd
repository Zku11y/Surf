extends CharacterBody3D
@onready var label: Label = $"../CanvasLayer/Label"
@onready var head: Node3D = $head
@export var speed := 20.0
@export var sprint_speed := 10.0
const walking_speed := 5.0
@export var jump_velocity := 10
const mouse_sens := 0.1
var lerp_speed := 9.0
const friction_offset := 10
var sprinting := false
@export var acel := 10
var acel_vect := Vector3.ZERO
@export var friction_rate := 2
var direction := Vector3.ZERO
var input_dir := Vector2.ZERO
var jumping := false
var acceleration
#var look_dir := Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#look_dir.y = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * mouse_sens)
		head.rotate_x(deg_to_rad(-event.relative.y) * mouse_sens)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-70), deg_to_rad(70))


func _physics_process(delta: float) -> void:
	var look_dir = head.get_global_transform().basis
	label.text = str(int(velocity.length()))
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


	if not is_on_floor():
		print("flying!!!")
		#velocity += get_gravity() * delta
		#velocity = velocity.move_toward(Vector3(0, -1000, 0), delta * 20)
		velocity.y -= 30 * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor() and !jumping:
		velocity.y = jump_velocity
		jumping = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		jumping = false
	var forward_dir = -look_dir.z.normalized()
	forward_dir.y = 0
	var side_dir = look_dir.x
	input_dir = Input.get_vector("left", "right", "front", "back")
	#direction = lerp(direction, (transform.basis * (Vector3(input_dir.x, 0, 0) + (forward_dir * -input_dir.y))).normalized(), lerp_speed * delta)
	sprinting = Input.is_action_pressed("sprint")
	#print(sprinting)
	if input_dir != Vector2.ZERO:
		# intended direction based on input
		direction = (forward_dir * -input_dir.y + side_dir * input_dir.x).normalized()
		if is_on_floor():
			if sprinting:
				accelerate(direction, delta, sprint_speed)
			else:
				accelerate(direction, delta, speed)
		else:
			air_accelerate(direction, delta, speed)	
			#velocity.x = lerp(velocity.x, direction.x * speed, acel * delta)
			#velocity.z = lerp(velocity.z, direction.z * speed, acel * delta)
	else:
		if is_on_floor():
			friction(0.5, delta)
			#print("friction!!!!")
		#velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
func accelerate(input_dir : Vector3, delta, max_vel):
	#velocity = velocity.move_toward(input_dir * speed, acel * delta * 50)
	input_dir = input_dir.normalized()
	var proj_vel : float = velocity.dot(input_dir)
	var accel_Vel : float = acel * delta
	if proj_vel < max_vel:
		var alignment_boost = max(0, input_dir.dot(velocity.normalized())) * 0.5
		accel_Vel += alignment_boost * acel * delta
	if proj_vel + accel_Vel > max_vel:
		accel_Vel = max_vel - proj_vel
	velocity += input_dir * accel_Vel
	if velocity.length() > max_vel:
		velocity = velocity.move_toward(velocity.normalized() * max_vel, 0.1 * delta)
	print(" Speed: ", velocity.length(), "acceleration: ", accel_Vel)


func air_accelerate(input_dir : Vector3, delta, max_vel):
	#velocity = velocity.move_toward(input_dir * speed, acel * delta * 50)
	input_dir = input_dir.normalized()
	var proj_vel : float = velocity.dot(input_dir)
	var accel_Vel : float = acel * delta * 0.5
	if proj_vel + accel_Vel < max_vel:
		velocity += input_dir * accel_Vel
	#velocity = velocity.lerp(input_dir * velocity.length(), delta * 0.1)
	#var alignment_boost = max(0, input_dir.dot(velocity.normalized())) * 0.5
	#accel_Vel += alignment_boost * acel * delta
	accel_Vel += acel * delta
	#if proj_vel + accel_Vel > max_vel:
		#accel_Vel = max_vel - proj_vel
	#velocity += input_dir * accel_Vel
	#velocity.x += input_dir.x * (accel_Vel * 10)
	#velocity.z += input_dir.z * (accel_Vel * 10)
	#velocity = Vector3(velocity.x + (input_dir.x * accel_Vel * 3), velocity.y, velocity.z + (input_dir.z * accel_Vel * 3))
	#velocity = input_dir * ((accel_Vel + velocity.length()))
	#velocity = velocity.move_toward(input_dir * (accel_Vel + velocity.length()), acel)
	#if velocity.length() > max_vel:
		#velocity = velocity.normalized() * (velocity.length() - 0.1)
	#var print_shit : String(" Speed: ", velocity.length(), "acceleration: ", accel_Vel)
	#print("ve		locity forward = ", velocity.y)

func friction(friction_offset: float, delta: float) -> void:
	velocity = velocity.move_toward(Vector3.ZERO, friction_offset * delta * 14)
	#func friction
