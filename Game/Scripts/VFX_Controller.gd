extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	animated_sprite_2d.play("Start")
	
func _process(_delta):
	if !animated_sprite_2d.is_playing():
		queue_free()
