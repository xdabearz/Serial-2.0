extends CanvasLayer
#NOTE: Never connect managers to game scenes directly
@onready var health_bar = $HUD/HealthBar
@onready var currency_label = $HUD/CurrencyLabel
@onready var game_over_screen = $GameOverScreen


func _ready():
	var player = get_tree().get_root().get_node("Root").get_node("Player") as PlayerController
	player.playerHealthUpdated.connect(UpdateHealthBar)
	player.playerCurrencyUpdated.connect(UpdateCurrencyLabel)
	
	GameManager.gameOver.connect(ShowGameOverScreen)
	
	game_over_screen.visible = false

func UpdateHealthBar(newValue:int, maxValue:int):
	var barValue = float(newValue) / float(maxValue) * 100
	health_bar.value = barValue

func UpdateCurrencyLabel(newValue:int):
	currency_label.text = str(newValue)

func ShowGameOverScreen():
	game_over_screen.visible = true

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
