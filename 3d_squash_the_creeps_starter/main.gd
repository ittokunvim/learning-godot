extends Node


@export var mob_scene: PackedScene


func _ready() -> void:
	$UserInterface/Retry.hide()

func _on_mob_timer_timeout() -> void:
	# モブシーンのインスタンス化
	var mob = mob_scene.instantiate()
	
	# SpawnLocationノードの参照を取得
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# モブのランダムな出現位置を設定
	mob_spawn_location.progress_ratio = randf()
	
	# プレイヤーの位置を取得
	var player_position = $Player.position
	# プレイヤーの位置と生成したランダムなパスの位置を渡してモブを初期化
	mob.initialize(mob_spawn_location.position, player_position)
	
	# メインシーンに生成したモブを追加
	add_child(mob)
	
	# モブが踏みつけられた時、ScoreLabelにシグナルを送る
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())


func _on_player_hit() -> void:
	$MobTimer.stop()
	$UserInterface/Retry.show()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
