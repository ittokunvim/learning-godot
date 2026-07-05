extends Area2D

signal hit

@export var speed = 400 # プレイヤーの移動速度(pixels/sec).
var screen_size # ゲームの画面サイズ


func _ready() -> void:
	# ゲーム画面のサイズを取得
	screen_size = get_viewport_rect().size


func _process(delta: float) -> void:
	# 矢印キーに対応する方向を定義
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	# 矢印キーが押された方向の速度を定義と、アニメーションの実行と停止
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	# プレイヤーを動かす
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# プレイヤーの動く方向に対応するアニメーションを定義
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

# プレイヤーに当たり判定があった時に実行される関数
func _on_body_entered(_body: Node2D) -> void:
	hide()
	hit.emit()
	# 当たり判定を無効にする（この関数は当たり判定時、1度だけ実行される）
	$CollisionShape2D.set_deferred("disabled", true)

# プレイヤーの初期化を行う
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
