extends Node
#NOTE: Never connect managers to game scenes directly

var player : PlayerController
var playerOriginalPos

signal gameOver()

func PlayerEnteredResetArea():
	player.position = playerOriginalPos

func SpawnVFX(vfxToSpawn : Resource, position : Vector2):
	var vfxInstance = vfxToSpawn.instantiate()
	vfxInstance.global_position = position
	get_tree().get_root().get_node("Root").add_child(vfxInstance)
	
	return vfxInstance

func PlayerIsDead():
	emit_signal("gameOver")
	
#TODO: This function name is stupid but ive been drinking and lost all originality
func PlayerEnteredEndDoor():
	player.SwitchStateToUncontrollable()
	emit_signal("gameOver") #TODO: Temporarily insults you when you win til we get more win conditions
