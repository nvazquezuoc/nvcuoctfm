extends Node3D

var _input_list:Array = InputManager.create_empty()
var state:int = 0
var i_floor:int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	
	if (_input_list[InputManager.Indexes.OK] == InputManager.States.JustPressed):
		if(state == 0):
			$elevator.door_open(0)
		elif(state == 1):
			$elevator.door_close(0)
		elif(state == 2):
			$elevator.door_open(1)
		elif(state == 3):
			$elevator.door_close(1)
			pass
		i_floor -= 1
		$elevator.set_floor_number(i_floor)
		
		state = (state + 1) % 4
		pass
	pass
