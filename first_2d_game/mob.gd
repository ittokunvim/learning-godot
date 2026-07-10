extends RigidBody2D


# モブを画面外からランダムに配置する
func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()


func _process(delta: float) -> void:
	position.x += 5.0


# モブが画面外に出たら削除する
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
