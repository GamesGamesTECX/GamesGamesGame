extends CharacterBody3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENS = 0.5
var can_shoot = true
var is_dead = false
var world_camera = false

@onready var animated_sprite_2D = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var ray_cast_3D = $RayCast3D
@onready var shoot_sound = $ShootSound

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animated_sprite_2D.animation_finished.connect(shoot_animation_done)
	$CanvasLayer/DeathScreen/Panel/Button.button_up.connect(restart)

func _input(event):
	if is_dead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS
	
func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	if is_dead:
		return
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("change_camera"):
		if !world_camera:
			$"../CameraWorld".set_current(true)
			$CanvasLayer/CrossHair.hide()
			$CanvasLayer/GunBase.hide()
			world_camera = true
			return
		$Camera3D.set_current(true)
		$CanvasLayer/CrossHair.show()
		$CanvasLayer/GunBase.show()
		world_camera = false

func _physics_process(delta):
	if is_dead:
		return
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func restart():
	get_tree().reload_current_scene()
	pass
func shoot():
	if !can_shoot:
		return
	can_shoot = false
	animated_sprite_2D.play("shoot")
	shoot_sound.play()
	if ray_cast_3D.is_colliding() and ray_cast_3D.get_collider().has_method("kill"):
		ray_cast_3D.get_collider().kill()

func shoot_animation_done():
	can_shoot = true

func kill():
	is_dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
