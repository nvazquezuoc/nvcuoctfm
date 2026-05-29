extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Master start")
	GlobalVariables.randomize_rng()
	GlobalVariables.begin_vars()
	$MeshInstance3D._start()
	print("Master ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
