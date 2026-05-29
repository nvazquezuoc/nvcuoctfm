extends RefCounted

class_name EnemyBrain

var map_node:MapNode
var dict_valid:Dictionary[Vector2i, int]

func level_start_setup()->void:
	map_node = GameplayManager.instance.get_map_node()
	dict_valid = map_node.dict_map_data["v"]
	pass
	
func get_new_destination()->Vector3:
	var idx:int = GlobalVariables.randi_l(0, dict_valid.keys().size()-1)# % 
	return map_node.tilecoord2worldposition(dict_valid.keys()[idx])
