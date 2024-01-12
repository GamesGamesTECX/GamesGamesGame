extends Node

@onready var interaction_area: InteractionArea = $interaction_area
@onready var lamp_switch: SpotLight3D = $SpotLight3D
@onready var light_switch: DirectionalLight3D = $DirectionalLight3D

@export var is_lamp: bool

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	if is_lamp:
		if lamp_switch.visible:
			lamp_switch.visible = false
		else:
			lamp_switch.visible = true
	else:
		if light_switch.light_energy <= 0.3:
			light_switch.light_energy = 1
		else:
			light_switch.light_energy = 0.2
