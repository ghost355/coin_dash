extends Node

@export var coin_scene: PackedScene
@export var powerup_scene: PackedScene
@export var cactus_scene: PackedScene
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
	# What happens when you've picked up all the coins = Next Level
	if playing and get_tree().get_nodes_in_group("coins").size() == 0:
		level += 1
		time_left += 5
		spawn_cactus()
		spawn_coins()
		$PowerupTimer.wait_time = randf_range(5, 10)
		$PowerupTimer.start()


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


func spawn_cactus():
	if level % 2 == 0:
		var k = cactus_scene.instantiate()
		add_child(k)
		k.screensize = screensize
		k.position = Vector2(
			randi_range(screensize.x * 0.2, screensize.x * 0.8),
			randi_range(screensize.y * 0.2, screensize.y * 0.8)
		)


func spawn_coins():
	$LevelSound.play()
	for i in level + 4:
		var c = coin_scene.instantiate()  # create a new coin node
		add_child(c)  # add the new coin node to the root node
		c.screensize = screensize  # share gotten screensize with coin node
		c.position = Vector2(
			randi_range(screensize.x * 0.05, screensize.x * 0.95),
			randi_range(screensize.y * 0.05, screensize.y * 0.95)
		)


func _on_game_timer_timeout() -> void:
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left == 0:
		game_over()


func _on_player_hurt() -> void:
	$HitSound.play()
	game_over()


func _on_player_pickup(type) -> void:
	match type:
		"coin":
			$CoinSound.play()
			score += 1
			$HUD.update_score(score)
		"powerup":
			$PowerupSound.play()
			time_left += 5
			$HUD.update_timer(time_left)


func game_over():
	$EndSound.play()
	playing = false
	$GameTimer.stop()
	get_tree().call_group("coins", "queue_free")
	get_tree().call_group("powerups", "queue_free")
	get_tree().call_group("obstacles", "queue_free")
	$HUD.show_game_over()
	$Player.die()


func _on_hud_start_game() -> void:
	new_game()


func _on_powerup_timer_timeout() -> void:
	var p = powerup_scene.instantiate()
	add_child(p)
	p.screensize = screensize
	p.position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))
