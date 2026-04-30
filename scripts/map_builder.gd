@tool
extends Node3D


@export_tool_button("SAVE")
var __test_btn:Callable = _save_map_func
@export_tool_button("BUILD")
var __test_btn2:Callable = _build
@export var texture_map:Texture
@export
var map_node:Node3D
@export
var map_name:String
@export_dir
var save_dir:String
@export
var meshes_map:Node3D
@export
var meshes_props:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _build()->void:
	if(texture_map):
		$map_base.texture_map = texture_map
	$map_base._meshes_map = meshes_map
	$map_base.regenerate()
	pass

func _save_map_func()->void:
	if(map_name != ""):
		var pck:PackedScene = PackedScene.new()
		pck.pack(map_node)
		ResourceSaver.save(pck, save_dir+"/"+map_name+".scn")
	else:
		print("NO NAME!")
	pass
