extends Area3D

class_name InteractionArea

@export var action_name: String = "interact"
var interact: Callable = func():
	pass

func _on_body_entered(body):
	print("Voce entrou na area para interagir com lampada")
	InteractionManager.register_area(self)

func _on_body_exited(body):
	print("Voce saiu da area para interagir com lampada")
	InteractionManager.unregister_area(self)
