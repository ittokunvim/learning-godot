extends RigidBody2D


func _ready() -> void:
	# モブのアニメーションの配列を取得
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	# アニメーションをランダムに設定
	$AnimatedSprite2D.animation = mob_types.pick_random()
	# アニメーションを実行
	$AnimatedSprite2D.play()


func _process(delta: float) -> void:
	position.x += 5.0


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# モブが画面外に出たら削除する
	queue_free()
