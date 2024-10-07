extends InventoryGrid

class_name ItemDominoGrid

@export var normal_texture:Texture = null
@export var hover_texture:Texture = null
@export var valid_texture:Texture = null
@export var invalid_texture:Texture = null
@export var merge_texture:Texture = null

func set_to_normal_texture():
	texture = normal_texture
	
func set_to_hover_texture():
	texture = hover_texture
	
func set_to_valid_texture():
	texture = valid_texture
	
func set_to_invalid_texture():
	texture = invalid_texture
	
func set_to_merge_texture():
	texture = merge_texture

func on_hover():
	set_to_hover_texture()

func on_unhover():
	set_to_normal_texture()
