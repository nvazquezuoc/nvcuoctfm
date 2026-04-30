extends VBoxContainer

@onready
var btn_new_game:Button = $btn_new_game
@onready
var btn_scoreboard:Button = $btn_scoreboard
@onready
var btn_quit:Button = $btn_quit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	btn_new_game.pressed.connect(func()->void:
		#UI_Manager.instance.make_visible(&"game")
		MainGameNode.goto_new_game())
	
	btn_scoreboard.pressed.connect(func()->void:
		UI_Manager.instance.make_visible(&"score"))
	
	btn_quit.pressed.connect(func()->void:
		ResourceSaver.save(MainGameNode.instance.save_data, "res://SaveData.tres")
		get_tree().quit())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
