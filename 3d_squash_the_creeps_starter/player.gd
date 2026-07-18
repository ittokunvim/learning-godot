extends CharacterBody3D


# プレイヤーの移動速度
@export var speed = 14
# 空中の落下速度
@export var fall_acceleration = 75


var target_velocity = Vector3.ZERO


func _physics_process(delta: float) -> void:
	# 入力した方向を格納する変数を定義
	var direction = Vector3.ZERO

	# 進行方向を更新
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# basisプロパティでノードの回転を計算
		$Pivot.basis = Basis.looking_at(direction)

	# 地表速度
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# 鉛直速度、キャラクタが空中にいる場合、落下する（重力）
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# キャラクタを動かす
	velocity = target_velocity
	move_and_slide()
