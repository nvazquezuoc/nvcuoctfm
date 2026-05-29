extends VBoxContainer

@export var total_entry:Control
@export var board:Control
@export var home_button:Button
var active_entries:Array[Control] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	home_button.pressed.connect(func()->void:
		MainGameNode.goto_main_menu()
		pass)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func show_data()->void:
	reset_list()
	update_total("Total", GlobalVariables.play_dic[&"totalpoints"])
	var tagdict:Dictionary = GlobalVariables.play_dic[&"tagpoints"]
	for key in tagdict:
		add_entry(key, tagdict[key])
	pass


func reset_list()->void:
	for node in active_entries:
		node.queue_free()
	active_entries.clear()
	pass


func update_total(val1:Variant="", val2:Variant="")->void:
	update_entry(total_entry, str(val1), str(val2))
	pass

func add_entry(val1:Variant="", val2:Variant="")->void:
	var new_entry:Control = total_entry.duplicate()
	update_entry(new_entry, str(val1), str(val2))
	board.add_child(new_entry)
	active_entries.push_back(new_entry)
	pass
	

func update_entry(node:Control=null, val1:String="", val2:String="")->void:
	node.get_node(^"lbl_name").text = val1
	node.get_node(^"lbl_points").text = val2
	pass
