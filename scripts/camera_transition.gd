##Referência: https://www.youtube.com/watch?v=AIYdGRkd_9E
extends Node
@onready var global_camera = $"../CameraWorld"
@onready var player = $"../Player"
@export var duration: float = 1.0
var temp_camera: Camera3D
var player_camera: Camera3D
var transitioning: bool = false
var cross_hair
var gun_base
var player_script
var can_shoot: bool = true
var can_transition_camera: bool = true

func _ready():
	get_player_camera()
	get_player_cross_hair_and_control()

func get_player_camera():
	for child in player.get_children():
		if child is Camera3D:
			player_camera = child as Camera3D
			break
	
func get_player_cross_hair_and_control():
	for child in player.get_children():
		if child is CanvasLayer:
			for inside_child in child.get_children():
				if inside_child as ColorRect:
					cross_hair = inside_child
				if inside_child as Control:
					gun_base = inside_child

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

func change_camera():
	if global_camera.current:
		can_shoot = true
		await global_camera.transition(global_camera, player_camera)
		cross_hair.show()
		gun_base.show()
		return
	elif can_transition_camera:
		can_shoot = false
		global_camera.transition(player_camera, global_camera)
		cross_hair.hide()
		gun_base.hide()
	
func _on_player_can_shoot_changed(value):
	can_shoot = value

func _on_player_can_transition_camera_changed(value):
	can_transition_camera = value
