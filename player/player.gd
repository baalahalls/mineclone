extends CharacterBody3D

@export var mouse_sensitivity: float = 0.002

@export var movement_speed: float = 4.3
@export var jump_velocity: float = 5.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = %Camera

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:
		
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)

		camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:

	if not is_on_floor():

		velocity.y -= gravity * delta
	else:

		if Input.is_action_just_pressed("jump"):

			velocity.y = jump_velocity



	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	var movement_direction: Vector3 = transform.basis * Vector3(input_vector.x, 0, input_vector.y)

	velocity.x = movement_direction.x * movement_speed
	velocity.z = movement_direction.z * movement_speed

	move_and_slide()
