extends interactable_base

var code_idx:int = -1

func _ready() -> void:
	super()
	pass

func event(chr:NavigableCharacter)->bool:
	#GameplayManager.instance.add_keys(1)
	#print(GlobalVariables.play_dic[&"num_codes"][code_idx])
	GlobalVariables.play_dic[&"got_code"][code_idx] = true
	GlobalVariables.add_points(&"Take code", 10)
	#print("GOT IDX ", code_idx)
	if(parent_interaction):
		parent_interaction.disable_secondary_interaction()
	else:
		interaction_node.disable_event(chr)
	#parent_interaction.event(chr)
	return true

func prepare()->void:
	#print("Code prepared: ",GlobalVariables.last_code_idx)
	code_idx = GlobalVariables.last_code_idx
	pass
