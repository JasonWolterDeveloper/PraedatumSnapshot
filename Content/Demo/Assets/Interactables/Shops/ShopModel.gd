extends Node3D


func _ready() -> void:
	$AnimationPlayer.play("ShopBob")
	$ShopSign.mesh.text = "Consume"
