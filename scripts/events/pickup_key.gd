extends Node3D

func _ready() -> void:
	set_process(false)

func event(chr:NavigableCharacter)->bool:
	GameplayManager.instance.add_keys(1)
	$"./".visible = false
	return true
