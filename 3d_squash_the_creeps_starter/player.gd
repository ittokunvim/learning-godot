extends CharacterBody3D


# プレイヤーがモブにあたった時に発信するシグナル
signal hit


# プレイヤーの移動速度
@export var speed = 14
# 空中の落下速度
@export var fall_acceleration = 75
# ジャンプ時、プレイヤーに加わる垂直方向の値
@export var jump_impulse = 20
# 踏み付け時、プレイヤーに加わる垂直方向の値
@export var bounce_impulse = 16

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
		# アニメーションの速度を4倍
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1

	# 地表速度
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# 鉛直速度、キャラクタが空中にいる場合、落下する（重力）
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	# プレイヤーが床にいてジャンプボタンが押された時、ジャンプする
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
	
	# すべての衝突を処理
	for index in range(get_slide_collision_count()):
		# プレイヤーとの衝突を取得
		var collision = get_slide_collision(index)
		
		# 下記のコード`is_in_group("mob")`のためのコード
		# もしも1フレームでモブの衝突が重複していると以下のコードでポインタエラーとなるため
		if collision.get_collider() == null:
			continue
		
		# 衝突がモブであった場合
		if collision.get_collider().is_in_group("mob"):
			# モブの衝突を取得
			var mob = collision.get_collider()
			
			# 踏みつけで検出されていることをチェック
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# モブを踏みつけ、プレイヤーを跳ねさせ、処理を抜ける
				mob.squash()
				target_velocity.y = bounce_impulse
				break

	# キャラクタを動かす
	velocity = target_velocity
	move_and_slide()
	
	# 孤を描くようにジャンプする
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse


# プレイヤーがモブにあたった時にシグナルを発信して、削除する
func die():
	hit.emit()
	queue_free()


@warning_ignore("unused_parameter")
func _on_mob_detector_body_entered(body: Node3D) -> void:
	die()
