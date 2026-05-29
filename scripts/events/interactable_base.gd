extends Node3D

class_name interactable_base

@export var is_lockable:bool = false
@export var is_touchable:bool = false
@export var interaction_icon:Texture = load("res://resources/textures/question_icon.png")
@export var points_of_interest:Array[Marker3D]
var lock_interaction:interactable_base
var parent_interaction:interactable_base
var interaction_node:Node3D

signal event_finished

func _ready() -> void:
	set_process(false)

func event(chr:NavigableCharacter)->bool:
	event_finished.emit()
	return true

func on_enter(chr:NavigableCharacter)->void:
	GameplayManager.instance.put_text()
	if(chr):
		chr.interactable_element = self
		if(lock_interaction):
			GameplayManager.instance.set_interaction_icon(lock_interaction.interaction_icon)
			lock_interaction.on_enter(null)
			pass
		else:
			GameplayManager.instance.set_interaction_icon(interaction_icon)
	pass

func on_exit(chr:NavigableCharacter)->void:
	if(chr.interactable_element == self):
		chr.interactable_element = null
		GameplayManager.instance.set_interaction_icon()
		GameplayManager.instance.put_text()
	pass

func add_secondary_interaction(other:interactable_base)->void:
	lock_interaction = other
	other.parent_interaction = self
	points_of_interest[0].add_child(other)
	pass
	
func disable_secondary_interaction()->void:
	lock_interaction.visible = false
	lock_interaction = null
	pass
	
func prepare()->void:
	pass
