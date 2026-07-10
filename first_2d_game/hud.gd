extends CanvasLayer

# ボタンが押された時にメインに通知する
signal start_game


# メッセージを表示し、タイマーもスタートする
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()


# メッセージを表示し、ゲームーオーバーをプレイヤーに伝える
func show_game_over():
	show_message("Game Over")
	# タイマーが終わるまでメッセージを表示する
	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# ボタンを表示するのに少し遅延させる
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()


# 更新されたスコアを表示する
func update_score(score):
	$ScoreLabel.text = str(score)


# スタートボタンを隠し、ゲームを開始する
func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()


# メッセージを隠す
func _on_message_timer_timeout() -> void:
	$Message.hide()
