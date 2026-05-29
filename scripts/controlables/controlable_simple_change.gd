extends Controlable_base

var other_controlable:Variant = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if (_input_list[InputManager.Indexes.OK] == InputManager.States.JustPressed):
		if(is_instance_valid(interactable_element)):
			interactable_element.event(other_controlable)
			#print("A")
	pass
