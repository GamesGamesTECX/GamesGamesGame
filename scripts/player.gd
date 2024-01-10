#Referência: https://www.youtube.com/watch?v=jzbgH4AMtI8&t=1097s
extends CharacterBody3D
const WALK_SPEED = 1.5
const RUN_SPEED = 3.0
const ROTATION_SPEED = 2.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENS = 0.1
var can_shoot = true
var can_transition_camera = true
signal can_shoot_changed(value: bool)
signal can_transition_camera_changed(value: bool)
var is_dead = false

@onready var animated_sprite_2D = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var ray_cast_3D = $RayCast3D
@onready var shoot_sound = $ShootSound
@onready var camera = $"../CameraWorld"
@onready var player_camera = $Camera3D
@onready var cross_hair = $CanvasLayer/CrossHair
@onready var gun_base = $CanvasLayer/GunBase
@onready var player = $"."
@onready var player_body = $CollisionShape3D/body
var body_animation_player

func _ready():
	get_body_animation_player()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animated_sprite_2D.animation_finished.connect(shoot_animation_done)
	$CanvasLayer/DeathScreen/Panel/Button.button_up.connect(restart)
	
func get_body_animation_player():
	for child in player_body.get_children():
		if child is AnimationPlayer:
			body_animation_player = child
			break

func _input(event):
	if is_dead: return
	if event is InputEventMouseMotion and !camera.current: rotation_degrees.y -= event.relative.x * MOUSE_SENS
	
func _process(delta):
	if Input.is_action_just_pressed("exit"): get_tree().quit()
	if Input.is_action_just_pressed("restart"): restart()
	if is_dead: return
	if Input.is_action_just_pressed("shoot"): shoot()
	if Input.is_action_just_pressed("change_camera"): change_camera()

func _physics_process(delta):
	if is_dead: return
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction = (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_pressed("rotate_left") and camera.current:
		player.rotate_y(delta * ROTATION_SPEED)
	elif Input.is_action_pressed("rotate_right") and camera.current:
		player.rotate_y(-delta * ROTATION_SPEED)
	if direction and camera.current:
		if input_dir == Vector2(0, 1):
			body_animation_player.play("Rig|man_walk_in_place")
			velocity.x = direction.x * WALK_SPEED
			velocity.z = direction.z * WALK_SPEED
		elif input_dir == Vector2(0, -1):
			if Input.is_action_pressed("run_forward"):
				body_animation_player.play("Rig|man_walk_in_place")
				velocity.x = direction.x * RUN_SPEED
				velocity.z = direction.z * RUN_SPEED
			else:
				body_animation_player.play("Rig|man_walk_in_place")
				velocity.x = direction.x * WALK_SPEED
				velocity.z = direction.z * WALK_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
		body_animation_player.play("Rig|man_idle")
	move_and_slide()

func restart():
	get_tree().reload_current_scene()
	
func shoot():
	if !can_shoot: return
	can_shoot = false
	can_transition_camera = false
	animated_sprite_2D.play("shoot")
	shoot_sound.play()
	if ray_cast_3D.is_colliding() and ray_cast_3D.get_collider().has_method("kill"):
		ray_cast_3D.get_collider().kill()

func shoot_animation_done():
	can_shoot = true
	can_transition_camera = true
	emit_signal("can_shoot_changed", can_shoot)
	emit_signal("can_transition_camera_changed", can_shoot)
func kill():
	is_dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func change_camera():
	if camera.current:
		can_shoot = true
		await camera.transition(camera, player_camera)
		cross_hair.show()
		gun_base.show()
		return
	elif can_transition_camera:
		can_shoot = false
		camera.transition(player_camera, camera)
		cross_hair.hide()
		gun_base.hide()
