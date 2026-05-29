extends interactable_base

func _ready() -> void:
	set_process(false)

func event(chr:NavigableCharacter)->bool:
	if(0 < GlobalVariables.play_dic[&"keys"]):
		GameplayManager.instance.add_keys(-1)
		GameplayManager.instance.load_next()
		$".".visible = false
		return true
	else:
		print("Not enough keys!")
		return false
