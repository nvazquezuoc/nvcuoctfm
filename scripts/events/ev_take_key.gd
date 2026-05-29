extends interactable_base



func event(chr:NavigableCharacter)->bool:
	GameplayManager.instance.add_keys(1)
	GlobalVariables.add_points(&"Take keys", 10)
	if(parent_interaction):
		parent_interaction.disable_secondary_interaction()
	else:
		interaction_node.disable_event(chr)
	#parent_interaction.event(chr)
	return true
