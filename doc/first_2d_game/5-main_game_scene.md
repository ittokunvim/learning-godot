# メインシーン

> 参考：https://docs.godotengine.org/ja/4.x/getting_started/first_2d_game/05.the_main_game_scene.html

今まで作成した全てをまとめ、遊べるゲームにする時が来ました！

新しいシーンを作成し、Nodeクラスを追加してMainという名前にします。
ここで使用するのはNode2DではなくNodeを使う理由は、ゲームロジックを扱うノードであり、2D機能が不要なためです。

インスタンスボタンをクリックし、`player.tscn`を選択します。

次にMainの子ノードとして以下のノードを追加します。

| クラス名 | 名前            | 説明                         |
| -------- | --------------- | ---------------------------- |
| Timer    | (MobTimer)      | モブが出現する頻度を制御する |
| Timer    | (ScoreTimer)    | 1秒ごとに得点を上げる        |
| Timer    | (StartTimer)    | 開始する前に遅延させる       |
| Marker2D | (StartPosition) | プレイヤーの開始位置を示す   |

各Timerノードの`Wait Time`プロパティを次のように設定します。

- MobTimer: 0.5
- ScoreTimer: 1.0
- StartTimer: 2.0

さらにStartTimerの`One Shot`プロパティを`On`に設定し、StartPositionノードの`Position`を`(240, 450)`に設定します。

## モブの生成

メインノードで新しいモブを生成する時に、ランダムな位置に表示させたいとします。
シーンドックでメインノードからPath2DのMobPathという名前の子ノードを追加します。

追加するとウィンドウが出てきて、中央のアイコン（点を空きスペースに追加）を選択、
表示されているコーナーにクリックでポイントを追加してパスを描画します。
ポイントをグリッドにスナップするには「グリッドスナップを使う」が選択されていることを確認します。
このオプションは「選択ノードをロック」ボタンの左側の「交差する線と磁石」アイコンで表示されています。

パスを時計回りに描画した後、「曲線を閉じる」ボタンをクリックするとパスが完成します。

パスを定義したらMobPathの子としてPathFollow2Dノードを追加し、MobSpawnLocationという名前をつけます。
このノードは自動的に回転し、パスの移動に従うので、パスに沿ってランダムな位置と方向を選択できます。

## メインスクリプト

Mainにスクリプトをアタッチします。
スクリプトに以下のコードを追加して、インスタンス化するMobシーンを選択できるようにします。

```godotengine
extends Node

@export var mob_scene: PackedScene
var score
```

Mainノードをクリックすると、インスペクタの`main.gd`の`Mob Scene`プロパティが見えるようになります。

このプロパティの値は2つの方法で指定することができます。

- ファイルシステムパネルから`mob.tscn`をドラッグし、MobSceneプロパティにドロップします。
- 空の隣にある下矢印をクリックして「読み込み」を選択し、`mob.tscn`を選択します。

次にシーンドックのMainノードの下のPlayerシーンのインスタンスを選択し、シグナルドックを開きます。

Playerノードのシグナルリストから`hit`シグナルを選択し、接続ダイアログを開きます。
ゲームが終了した時に必要な処理を行う`game_over`という名前の新しい関数をこれから作ります。
シグナル接続ダイアログの下にある受信側メソッドに`game_over`と入力し接続をクリックします。
Playerから`hit`シグナルが発火された時、Mainスクリプト側で処理できるようになります。

以下のコードを追加し、新しいゲームのセットアップを行う`new_game`関数も追加します。

```godotengine
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
```

それでは各タイマーノードの`timeout()`シグナルをメインスクリプトに接続しましょう。
3つのタイマーそれぞれについて該当するタイマーを選択し、シグナルタブの`timeout()`シグナルを選択し接続します。

3つのタイマー全ての設定が完了すると、`timeout()`シグナルに対応する接続が緑色で表示されます。

次に以下のコードを追加して、タイマーに動作を定義します。
StartTimerが他の2つのタイマーを起動し、ScoreTimerがスコアを1ずつ増加させます。

```godotengine
func _on_score_timer_timeout():
	score += 1

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
```

`_on_mob_timer_timeout()`では、モブのインスタンスを作成し、Path2Dにそってランダムに開始位置を選び、モブを動かします。
PathFollow2Dノードのパスに沿って自動的に回転するので、これを使ってモブの方向と位置を選択します。
移動速度は`150.0~250.0`の間でランダムにします。

注意点として、新しいインスタンスは`add_child()`を使ってシーンに追加しなければなりません。

```godotengine
func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
```

Godotでは角度を必要とする関数では度数ではなくラジアンを使用します。
円周率はラジアンの半回転を表し、約`3.1415`です。

## シーンのテスト

シーンをテストして動作を確認してみましょう。
`new_game`関数を`_ready()`に追加します。

```godotengine
func _ready():
	new_game()
```

プレイヤーの移動、モブの生成、プレイヤーとモブの当たり判定をチェックします。

全て動作していることが確認できたら上記の`_ready()`のコードを元に戻します。

次のレッスンではユーザーインターフェイスを見ていきます。
タイトル画面を追加して、スコアを表示します。
