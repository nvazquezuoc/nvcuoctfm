extends Node

class_name InputManager

enum Indexes {
	AXIS1,
	AXIS2,
	OK,
	CANCEL,
	MAX
}

enum States {
	JustReleased = -1,
	Released = 0,
	Pressed = 1,
	JustPressed = 2,
	MAX
}

var _input_list : Array = []
@export var target : Node = null
static var _instance:InputManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	_input_list = create_empty()
	if(not is_instance_valid(_instance)):
		_instance = self
		set_target(target)
	else:
		print("BIG ERROR")
	pass # Replace with function body.
	
func set_target(new_target=null)->void:
	if(target):
		target._input_list = create_empty()
	target = new_target
	if(target):
		target._input_list = _input_list
	
func set_btn_state(idx:int, action:StringName)->void:
	if(Input.is_action_pressed(action)):
		if(Input.is_action_just_pressed(action)):
			_input_list[idx] = States.JustPressed
		else:
			_input_list[idx] = States.Pressed
	else:
		if(Input.is_action_just_released(action)):
			_input_list[idx] = States.JustReleased
		else:
			_input_list[idx] = States.Released
		pass
		
func set_axis_state(idx:int, negative:StringName, positive:StringName)->void:
	_input_list[idx] = Input.get_axis(negative, positive)
	pass

func _physics_process(delta: float) -> void:
	set_axis_state(Indexes.AXIS1, &"ui_left", &"ui_right")
	set_axis_state(Indexes.AXIS2, &"ui_up", &"ui_down")
	set_btn_state(Indexes.OK, &"ui_accept")
	set_btn_state(Indexes.CANCEL, &"ui_cancel")
	pass
	
static func create_empty()->Array:
	var result:Array = []
	result.resize(Indexes.MAX)
	for i in range(0, Indexes.MAX):
		result[i] = 0
	return result
