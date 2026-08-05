# モブシーンをデザイン

> 参考：https://docs.godotengine.org/ja/4.x/getting_started/first_3d_game/04.mob_scene.html

このパートではモンスター（モブ）のコードを作成します。
次のレッスンではモンスターをプレイエリアにランダムに配置します。

では新しいシーンでモンスターを作成します。
ノード構造はプレイヤーシーンににています。

Mobという名前のCharacterBody3Dノードを作成します。
次にPivotという名前のNode3DノードをMobの子ノードに追加します。
そして`mob.glb`ファイルをPivotにドラッグし、モンスターの3Dモデルをシーンに追加し、名前をCharacterとします。

CollisionShape3DをMobの子ノードに追加します。
インスペクタのShapeプロパティにBoxShape3Dを割り当てます。
割り当てたらサイズをモデルの適切な大きさに合わせます。

## 古いモンスターを削除する

私たちはこのゲームレベルで一定時間毎にモンスターを生成します。
もしかすると誤操作で無限大の数のモンスターを生成してしまうかもしれません。
モブの描くインスタンスにはメモリと処理コストがあり、モブが画面外にいる時にそのコストを支払いたくありません。

モンスターが画面外にいたら削除します。
GodotにはVisibleOnScreenNotifier3Dというノードが画面から離れたら検知するノードがあるので、それを使ってモブを削除します。

オブジェクトのインスタンスを生成し続ける場合に、インスタンスを常に生成・破棄するコストを回避するための手法にプーリングというものがあります。
これはオブジェクトの配列をあらかじめ作成しておき、それを何度も再利用するというものです。

GDScriptを使用する場合、通常これは必要ありません。
プールを使用する主な理由は、`C#, Lua`のようなガベージコレクション方式を採用した言語で発生するフリーズを回避するためです。
GDScriptは、そのような問題がない別のメモリ管理手法である「参照カウント」を採用しています。

MobノードにVisibleOnScreenNotifier3Dを追加します。
するとピンク色のボックスが現れ、このボックスが画面外にいくと、ノードがシグナルを発信します。

## モブの動きをコード化する

それではモンスターの動きを組み込んでみましょう。
2ステップに分けて行い、まずモンスターを初期化する関数をMobノードに作成します。
次にランダム生成メカニズムを`main.tscn`に作成し、モンスターを初期化する関数を実行します。

ではMobノードにスクリプトをアタッチし、以下のコードを記述します。
`min_speed, max_speed`の2つのプロパティを定義し、ランダムな速度範囲を定義します。
これはあとでCharacterBody3D.velocityで使用します。

```godotengine
extends CharacterBody3D

# Minimum speed of the mob in meters per second.
@export var min_speed = 10
# Maximum speed of the mob in meters per second.
@export var max_speed = 18


func _physics_process(_delta):
	move_and_slide()
```

プレイヤーと同様に、`move_and_slide()`関数を呼び出してモブをマイフレーム動かします。
この時`velocity`はマイフレーム更新しません。
例え障害物に当たったとしても、モンスターが画面外に出るまで等速で動かすのです。

他に`velocity`を計算する関数を定義する必要があります。
この関数はモンスターをプレイヤーの方へ向かせ、動きの角度と速度をランダムにします。

この定義する関数には、モブの出現位置とプレイヤーの位置を引数にとります。

モブをプレイヤーの方に向かせ、Y軸を中心にランダムに回転させて角度をランダムにします。
以下の`randf_range()`には`-PI / 4, PI / 4`の間のランダムな角度を出力します。

```godotengine
# This function will be called from the Main scene.
func initialize(start_position, player_position):
	# We position the mob by placing it at start_position
	# and rotate it towards player_position, so it looks at the player.
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate this mob randomly within range of -45 and +45 degrees,
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-PI / 4, PI / 4))
```

次は速度を定義します。
先ほど定義した`min_speed, max_speed`を使用して`velocity`に掛けます。

```godotengine
func initialize(start_position, player_position):
	# ...

	# We calculate a random speed (integer)
	var random_speed = randi_range(min_speed, max_speed)
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)
```

## 画面から離れる

モブが画面外にでた時に削除します。
VisibleOnScreenNotifier3Dノードの`screen_exited`シグナルをMobに接続します。

VisibleOnScreenNotifier3Dを選択し、シグナルで`screen_exited()`を選択し、Mobに接続します。

これでMobスクリプトに`_on_visible_on_screen_notifier_3d_screen_exited()`という新しい関数が追加されます。
そこに`quere_free()`メソッドを呼び出し、モブを削除するというわけです。

```godotengine
func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
```

これでモンスターがゲームに参加する準備が整いました！
以下が`mob.gd`スクリプトの完成版です。

```godotengine
extends CharacterBody3D

# Minimum speed of the mob in meters per second.
@export var min_speed = 10
# Maximum speed of the mob in meters per second.
@export var max_speed = 18

func _physics_process(_delta):
	move_and_slide()

# This function will be called from the Main scene.
func initialize(start_position, player_position):
	# We position the mob by placing it at start_position
	# and rotate it towards player_position, so it looks at the player.
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate this mob randomly within range of -45 and +45 degrees,
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-PI / 4, PI / 4))

	# We calculate a random speed (integer)
	var random_speed = randi_range(min_speed, max_speed)
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)

func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
```
