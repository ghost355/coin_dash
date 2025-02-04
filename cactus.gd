extends Area2D
var screensize = Vector2.ZERO


func _ready():
	if randi() % 2:
		$Sprite2D.flip_h = true
