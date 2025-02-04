extends Node

@export var coin_scene: PackedScene
@export var playtime = 30

var level = 1
var score = 0
var time_left = 0
var screensize = Vector2.ZERO
var playing = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	$Player.hide()


func _process(delta: float) -> void:
	if playing and get_tree().get_nodes_in_group("coins").size() == 0:
		level += 1
		time_left += 5
		spawn_coins()


func new_game():
	playing = true
	level = 1
	score = 0
	time_left = playtime
	$Player.start()
	$Player.show()
	$GameTimer.start()
	spawn_coins()
	$HUD.update_score(score)
	$HUD.update_timer(time_left)


func spawn_coins():
	for i in level + 4:
		var c = coin_scene.instantiate()  # create a new coin node
		add_child(c)  # add the new coin node to the root node
		c.screensize = screensize  # share gotten screensize with coin node
		c.position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))


func _on_game_timer_timeout() -> void:
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left < 0:
		game_over()


func _on_player_hurt() -> void:
	game_over()


func _on_player_pickup() -> void:
	score += 1
	$HUD.update_score(score)


func game_over():
	playing = false
	$GameTimer.stop()
	get_tree().call_group("coins", "queue_free")
	$HUD.show_game_over()
	$Player.die()


func _on_hud_start_game() -> void:
	new_game()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_ESCAPE:
					get_tree().quit()
				KEY_ENTER:
					$StartButton.emit_signal("pressed")
