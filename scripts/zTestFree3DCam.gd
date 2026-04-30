extends Node3D

var _input_list:Array = InputManager.create_empty()
var SPEED := 0.2
var MOUSE_SPEED := 0.01

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2(_input_list[InputManager.Indexes.AXIS1], _input_list[InputManager.Indexes.AXIS2])
	var direction :Vector3= (transform.basis * Vector3(input_dir.x, 0, 0) + $Camera3D.global_basis * Vector3(0, 0, input_dir.y)).normalized() * SPEED
	
	position+=direction
	
	if(_input_list[InputManager.Indexes.CANCEL] == 2):
		if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SPEED)
		$Camera3D.rotate_x(-event.relative.y * MOUSE_SPEED)
