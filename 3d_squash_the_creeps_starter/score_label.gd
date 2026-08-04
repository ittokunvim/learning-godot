extends Label


var score = 0


# モブを踏みつけたら、スコアを増やす
func _on_mob_squashed():
	score += 1
	text = "Score: %s" % score
