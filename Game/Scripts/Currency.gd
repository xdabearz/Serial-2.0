extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var value = 1

func _on_body_entered(body):
	animated_sprite_2d.play("Collected")
	var player = body as PlayerController
	if player:
		player.CollectedCurrency(value)
		
func _process(delta):
	if !animated_sprite_2d.is_playing():
		queue_free()
