# モンスターの出現

> 参考：https://docs.godotengine.org/ja/4.x/getting_started/first_3d_game/05.spawning_mobs.html

このパートでは、パスに沿ってランダムにモンスターを出現させます。
最終的には、ゲームボード上をモンスターが歩き回ることになります。

パスを描画する前に、プロジェクト設定、一般からゲームの解像度を`720x540`に変更します。

## 出現パスの作成

2Dゲームのチュートリアルで行ったように、パスを設計しランダムな位置をサンプリングするためにPathFollow3Dノードを使用します。

しかし3Dの場合、パスを描くのは少し複雑です。
モンスターが画面のすぐ外に現れるようにゲームビューの周囲にパスを描きたいです。
しかしパスを描くと、カメラのプレビューでは見えないようになっています。

ビューの制限を確認するために、プレースホルダーメッシュを使用します。
2Dゲームを作成した時のようにビューを2分割します。
Camera3Dを選択し、Previewチェックボックスをクリックします。

### プレースホルダー用のシリンダーを追加する

プレースホルダメッシュを追加します。
Cylindersという名前のNode3DをMainノードに追加します。
CylindersにMeshInstance3Dノードを追加します。

インスペクタでMeshプロパティにCylinderMeshを割り当てます。

一番上のビューポートを平行投影ビュー(Top View)に変更します。

次に下部ビューポートを見ながら円柱を地面の平面上で移動させます。
グリッドスナップを使用するのがおすすめです。
円柱をカメラの視界の左上隅、すぐ外側に移動します。

MeshInstance3Dを複製し、Cylindersに追加します。
追加したらゲームエリア外の4隅にMeshInstance3Dを配置します。

円柱が白だと見えにくいので、新しいマテリアルを追加して目立つようにします。

3Dではマテリアルがサーフェスの色や光の反射などの視覚的プロパティを定義します。
これを利用して、メッシュの色を変更することができます。

4つのシリンダーを1度に全て更新することができます。
選択する時にシフトキーを押しながらクリックすると可能です。

インスペクタでMaterialプロパティでStandardMaterial3Dを割り当てます。
MaterialプロパティのStandardMaterial3Dを選択し、Albedoセクションを開きます。
色を選択し、明るいオレンジ色を設定します。

これでシリンダーをガイドとして使用できるようになりました。
シーンドックでCylindersを折りたたみます。

MainノードにPath3Dを追加します。
ツールバーに緑色のポイントを追加アイコンが出現するので選択します。

各シリンダーの中心をクリックしてポイントを作成します。
次に曲線を閉じるアイコンをクリックし、パスを閉じます。
点がずれている場合はドラッグして位置を変更します。

Path3DにPathFollow3Dノードを追加します。
2つのノードにそれぞれ`SpawoLocation, SpawnPath`と名前をつけます。

これで出現メカニズムのコードが準備できました。

## ランダムなモブの生成

Mainノードにスクリプトをアタッチします。

まずは変数をエクスポートして`mob.tscn`や他のスクリプトに割り当てをできるようにします。

```godotengine
extends Node

@export var mob_scene: PackedScene
```

モンスターは一定時間毎に出現させます。
そのためにタイマーを追加します。
しかしその前に`mob.tscn`に`mob_scene`プロパティを割り当てておきましょう。

Mainノードを選択し、`mob.tscn`をインスペクタのモブシーンのスロットにドラッグします。

次にMobTimerという名のTimerノードをMainに追加します。

Wait Timeプロパティを`0.5`秒に設定し、ゲーム実行時に自動的に起動するようにAutostartプロパティをオンにしておきます。

タイマーは`timeout`シグナルをWaitTimeが終了するたびに発信します。
これで`0.5`秒毎にモンスターを出現させることができるわけです。

ではシグナルで`timeout`を選択し、`_on_mob_timer_timeout()`関数を追加します。

モブの出現ロジックは以下の通りです。

1. モブシーンをインスタンス化。
2. 出現パスのランダムな位置をサンプリング。
3. プレイヤーの位置を取得。
4. モブの`initialize()`メソッドを呼び、ランダムな位置とプレイヤーの位置を渡す。
5. Mainノードの子としてモブを追加。

```godotengine
func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
```

上記の`randf()`は`0~1`の間のランダムな値を生成し、これはPathFollowノードの`progress_ratio`が期待する値になります。
設置したパスはカメラのビューポートを囲んでいるので、`0~1`のランダムな値はビューポートの端に沿ったランダムな位置になります！

いかが`moin.gd`の完全なコードです。

```godotengine
extends Node

@export var mob_scene: PackedScene


func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
```

ではシーンをテストしてみましょう。
モンスターが出現し、直線的に移動していれば成功です。
