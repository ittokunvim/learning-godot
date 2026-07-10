extends Node

@export var mob_scene: PackedScene # モブシーンを定義
var score

# ゲームオーバー時に実行される関数
func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()

	$HUD.show_game_over()

	$Music.stop()
	$DeathSound.play()


# ゲーム開始時に実行される関数
func new_game() -> void:
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()

	$HUD.update_score(score)
	$HUD.show_message("Get Ready")

	get_tree().call_group("mobs", "queue_free")

	$Music.play()


# タイムアウトごとにスコアを加算し反映する
func _on_score_timer_timeout() -> void:
	score += 1
	
	$HUD.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout() -> void:
	# モブシーンを生成
	var mob = mob_scene.instantiate()
	
	# Path2Dのランダムな位置を設定
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# モブが生成されるランダムな位置を定義
	mob.position = mob_spawn_location.position
	
	# モブが進む方向を定義
	var direction = mob_spawn_location.rotation + PI / 2

	# 進む方向にランダム性を追加
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# モブにランダム性を持つ移動速度を定義し、代入
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# メインシーンにモブを追加
	add_child(mob)
