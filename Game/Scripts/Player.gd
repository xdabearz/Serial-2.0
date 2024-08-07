extends CharacterBody2D
class_name PlayerController

#Originization (In Progress)
#ready and delta functions first, movement, actions, then animation
#node detection somewhere?

const SPEED = 100
const JUMP_VELOCITY = -250 #3 tiles high, 5-6 tiles wide
const GRAVITY = 500

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shooting_point = $Shooting_Point

var isAirborne = false

var isShooting = false
const SHOOT_DURATION = 0.249

var currentHealth:
	set(new_value):
		currentHealth = new_value
		emit_signal("playerHealthUpdated", currentHealth, MAX_HEALTH)
const MAX_HEALTH = 100

var currentCurrency = 0:
	set(new_value):
		currentCurrency = new_value
		emit_signal("playerCurrencyUpdated", currentCurrency)

signal playerHealthUpdated(newValue, maxValue)
signal playerCurrencyUpdated(newValue)

enum PlayerState {Normal, Hurt, Dead, Uncontrollable}

var currentState : PlayerState = PlayerState.Normal:
	set(new_value):
		currentState = new_value
		match currentState:
			PlayerState.Hurt:
				if is_on_floor():
					animated_sprite_2d.play("Hit_Stand")
				else:
					animated_sprite_2d.play("Hit_Jump")
			PlayerState.Dead:
				animated_sprite_2d.play("Die")
				set_collision_layer_value(2, false)
				GameManager.PlayerIsDead()
			PlayerState.Uncontrollable:
				set_collision_layer_value(2, false)

func _ready():
	currentHealth = MAX_HEALTH
	GameManager.player = self
	GameManager.playerOriginalPos = position

func _process(_delta):
	UpdateAnimation()

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		isAirborne = true
	elif isAirborne:
		PlayLandVFX()
		isAirborne = false
		
	if currentState == PlayerState.Hurt || currentState == PlayerState.Dead || currentState == PlayerState.Uncontrollable:
		velocity.x = 0
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("Jump") && !Input.is_action_pressed("Down") && is_on_floor():
		velocity.y = JUMP_VELOCITY
		PlayJumpUpVFX()
		
	var direction = Input.get_axis("Left","Right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0
	
	if Input.is_action_just_pressed("Shoot"):
		TryToShoot()
	
	
	
	if Input.is_action_pressed("Down") && Input.is_action_just_pressed("Jump")  && is_on_floor():
		position.y += 3
		
	move_and_slide()


func UpdateAnimation():
	if currentState == PlayerState.Dead:
		return
	elif currentState == PlayerState.Hurt:
		if animated_sprite_2d.is_playing():
			return
		else:
			currentState = PlayerState.Normal
	
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
		if velocity.x < 0:
			shooting_point.position.x = -26
		else:
			shooting_point.position.x = 26
		
	if is_on_floor():
		if abs(velocity.x) >= 0.1:
			
			var playingAnimationFrame = animated_sprite_2d.frame
			var playingAnimationName = animated_sprite_2d.animation
			
			if isShooting:
				animated_sprite_2d.play("Shoot_Run")
				
				if playingAnimationName == "Run":
					animated_sprite_2d.frame = playingAnimationFrame
			else:
				if playingAnimationName == "Shoot_Run" && animated_sprite_2d.is_playing():
					pass
				else:
					#animated_sprite_2d.frame = playingAnimationFrame
					animated_sprite_2d.play("Run")
		else:
			if isShooting:
				animated_sprite_2d.play("Shoot_Stand")
			else:
				animated_sprite_2d.play("Idle")
	else:
		animated_sprite_2d.play("Jump")
		
		if isShooting:
			animated_sprite_2d.play("Shoot_Jump")


#VFX
func PlayJumpUpVFX():
	var vfxToSpawn = preload("res://Game/Scenes/vfx_jump_up.tscn")
	GameManager.SpawnVFX(vfxToSpawn, global_position)

func PlayLandVFX():
	var vfxToSpawn = preload("res://Game/Scenes/vfx_land.tscn")
	GameManager.SpawnVFX(vfxToSpawn, global_position)

func PlayFireVFX():
	var vfxToSpawn = preload("res://Game/Scenes/vfx_player_gunfire.tscn")
	var vfxInstance = GameManager.SpawnVFX(vfxToSpawn, shooting_point.global_position)
	
	if animated_sprite_2d.flip_h:
		vfxInstance.scale.x = -1

func Shoot():
	var bulletToSpawn = preload("res://Game/Scenes/bullet.tscn")
	var bulletInstance = GameManager.SpawnVFX(bulletToSpawn, shooting_point.global_position)
	
	if animated_sprite_2d.flip_h:
		bulletInstance.direction = -1
	else:
		bulletInstance.direction = 1

func TryToShoot():
	if isShooting:
		return
		
	isShooting = true
	Shoot()
	PlayFireVFX()
	await get_tree().create_timer(SHOOT_DURATION).timeout
	isShooting = false

func ApplyDamage(damage : int):
	if currentState == PlayerState.Hurt || currentHealth == PlayerState.Dead:
		return
		
	currentHealth -= damage
	currentState = PlayerState.Hurt
	
	if currentHealth <= 0:
		currentHealth = 0
		currentState = PlayerState.Dead


func CollectedCurrency(value:int):
	currentCurrency += value
	
	#TODO: Mainly for testing possible run upgrades, currency restores a bit of health
	if currentHealth < MAX_HEALTH:
		currentHealth += value * 3
		if currentHealth > MAX_HEALTH:
			currentHealth = MAX_HEALTH
			
			
#Another drunken stupid name
func SwitchStateToUncontrollable():
	currentState = PlayerState.Uncontrollable
