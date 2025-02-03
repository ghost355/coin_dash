extends Area2D

signal pickup
signal hurt

@export var speed = 350
var velocity = Vector2.ZERO  # по смыслу это directon
var screensize: Vector2
var clamp_offset = 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screensize = DisplayServer.window_get_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += velocity * speed * delta

	position.x = clamp(position.x, 0 + clamp_offset, screensize.x - clamp_offset)
	position.y = clamp(position.y, 0 + clamp_offset, screensize.y - clamp_offset)

	if velocity.length() > 0:
		$AnimatedSprite2D.animation = "run"
	else:
		$AnimatedSprite2D.animation = "idle"
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0


func start():
	set_process(true)
	position = screensize / 2
	$AnimatedSprite2D.animation = "idle"


func die():
	$AnimatedSprite2D.animation = "hurt"
	set_process(false)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("coins"):
		area.pickup()
		pickup.emit()
	if area.is_in_group("obstacles"):
		hurt.emit()
		die()
