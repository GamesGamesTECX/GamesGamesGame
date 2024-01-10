##Referência: https://www.youtube.com/watch?v=AIYdGRkd_9E
extends Node
@onready var global_camera = $"../CameraWorld"
@onready var player = $"../Player"


@export var duration: float = 1.0
var temp_camera: Camera3D
var player_camera: Camera3D
var transitioning: bool = false

func _ready():
	for child in player.get_children():
		if child is Camera3D:
			player_camera = child as Camera3D
			break

func switch_camera(from, to):
	from.current = false
	to.current = true

func clear_current_camera():
	player_camera.set_current(false)
	global_camera.set_current(false)

func transition(from: Camera3D, to: Camera3D):
	clear_current_camera()
	if transitioning: return
	
	temp_camera = Camera3D.new()
	add_child(temp_camera)
	temp_camera.fov = from.fov
	temp_camera.cull_mask = from.cull_mask
	temp_camera.global_transform = from.global_transform 
	temp_camera.current = true
	transitioning = true

	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(temp_camera, "global_transform", to.global_transform , 0.5)

	await tween.finished
	to.current = true
	transitioning = false
	remove_child(temp_camera)

	


