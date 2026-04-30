extends Resource

class_name SaveData

@export
var score_list:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func add_score(score:int)->void:
	score_list.push_back([Time.get_datetime_string_from_system(), str(score)])
	pass
