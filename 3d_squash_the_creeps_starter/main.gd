extends Node


@export var mob_scene: PackedScene


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
