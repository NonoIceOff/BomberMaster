extends Control

func _process(delta):
	get_node("PlayersBars/Label").text = str(MultiplayerStats.players)+"/4 Joueurs"
	get_node("PlayersBars").value = MultiplayerStats.players
	
	if MultiplayerStats.players % 2 != 0:
		get_node("LaunchingButton").disabled = true
	else:
		get_node("LaunchingButton").disabled = false


func _on_game_settings_pressed():
	get_node("GameSettingsPanel").visible = !get_node("GameSettingsPanel").visible 
