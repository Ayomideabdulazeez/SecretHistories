extends Control


func _ready():
	if LoadQuotes.list2.empty() and LoadQuotes.list1.empty():
		LoadQuotes.load_files()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$VBoxContainer/ContinueButton.grab_focus()
	
	if !BackgroundMusic.is_playing():
		BackgroundMusic.play()
	
	# Slowly animate up the title text
#	get_tree().create_tween()\
#		.tween_property($VBoxContainer2/GameName, "percent_visible", 1.0, 5.0)\
#		.set_trans(Tween.TRANS_EXPO)\
#		.set_ease(Tween.EASE_IN)


func _input(event):
	if event.is_action_pressed("misc|fullscreen"):
		VideoSettings.set_fullscreen_enabled(!VideoSettings.fullscreen_enabled)


func _on_ContinueButton_pressed():
	pass   # Replace with function body once save/load implemented.


func _on_StartButton_pressed():
	$VBoxContainer/StartButton.text = "Loading"   # On slower machines, there's a significant delay before the Start Game Menu 
	$VBoxContainer/StartButton.disabled = true
	yield(get_tree().create_timer(0.1), "timeout")   # If we don't pause briefly, the engine doesn't have enough time to change the text
	var _error = get_tree().change_scene("res://scenes/ui/start_game_menu.tscn")


func _on_SettingsButton_pressed():
	$"%SettingsMenu".show()


func _on_CreditsButton_pressed():
	OS.shell_open("https://github.com/Mooses2k/SecretHistories/wiki") 


func _on_QuitButton_pressed():
	get_tree().quit()
