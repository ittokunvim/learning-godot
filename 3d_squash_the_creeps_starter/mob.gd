extends CharacterBody3D

# モブの最低速度
@export var min_speed = 10
# モブの最高速度
@export var max_speed = 18

func _physics_process(delta: float) -> void:
	move_and_slide()


# メインで呼び出される初期化関数
func initialize(start_position, player_position):
	# モブの位置を決めて、プレイヤーの方向に向かせる
	look_at_from_position(start_position, player_position, Vector3.UP)
	# モブを-45, 45度の間で回転させる（プレイヤーに一直線に向かわせないため）
	rotate_y(randf_range(-PI / 4, PI / 4))

	# ランダムな速度を計算
	var random_speed = randi_range(min_speed, max_speed)
	# モブの進む方向に計算した速度を定義
	velocity = Vector3.FORWARD * random_speed
	# モブのY軸の回転方向に基づいて回転させ、移動する
	velocity = velocity.rotated(Vector3.UP, rotation.y)


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
