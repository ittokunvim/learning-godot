# プレイヤーのコーディング

> 参考：https://docs.godotengine.org/ja/4.x/getting_started/first_2d_game/03.coding_the_player.html

このパートではプレイヤーの動きやアニメーション、衝突判定を設定します。

そのためには組み込みノードにはない機能が必要なので、スクリプトを追加します。
Playerノードをクリックして「スクリプトをアタッチ」します。

まずはオブジェクトに必要なメンバ変数を宣言します。

```godotengine
extends Area2D

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
```

「export」キーワードを使用することで、インスペクタでその値を設定できるようになります。
これは、ノードの組み込みプロパティと同じように値を調整したい場合に便利です。
Playerノードをクリックすると、プロパティがインスペクタに表示されるようになります。
もしここで値を変更すると、スクリプトで指定されたデフォルト値が上書きされます。

C#を使用している場合、新しいエクスポート変数やシグナルを確認したい時は常にプロジェクトアセンブリを際ビルドする必要ばあります。

`player.gd`の`_ready()`関数は、ノードがシーンツリーに入ると呼び出されます。
これはゲームウィンドウのサイズを調べる良いタイミングです。

```godotengine
func _ready():
	screen_size = get_viewport_rect().size
```

これで`_process()`関数を使用して、プレイヤーが何をするのか定義できます。
`_process()`はフレームごとに呼び出されるため頻繁に変更されることが予想されます。
プレイヤーの場合、入力をチェック、指定した方向に移動、適切なアニメーションを再生、といったことを行う必要があります。

まず入力をチェックします。
プレイヤーが押しているキーをチェックするにはプレジェクト設定の「インプットマップ」で定義されます。
ここでカスタムイベントを定義し、異なるキー、マウスイベント、などの入力を割り当てることができます。
今回はキーボードの矢印キーを四方向に割り当てます。

プロジェクト設定を開き、インプットマップをクリック、`move_right`アクションを追加します。
そしてキーを割り当てるために右側のプラスアイコンをクリックしてキーボードの`->`キーを押します。

同様の手順を`right, left, up, down`定義します。

キーが押されているかどうかは`Input.is_action_pressed()`を使用して検出できます。
押されていたら`true`を返します。

```godotengine
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
```

まず、`velocity`を0に設定し、次に各入力をチェックし、`velocity`から加算減算して方向を取得します。
例えばプレイヤーが右下を同時に押した場合`velocity`ベクトルは`(1, 1)`となります。
しかしこれではプレイヤーが斜めに移動すると水平方向に移動した時より早く移動できてしまします。

それをなくすためには`velocity`を正規化し、速度の長さを1に設定し、それから希望の速度を乗算します。

またAnimatedSprite2Dの`play(), stop()`を呼び出せるように、プレイヤーが移動中かどうか確認できるようにします。

> `$`は`get_node()`の省略形です。
> `$AnimatedSprite2D.stop()`は`get_node("AnimatedSprite2D).play()`と同じです。

移動方向がわかったので、プレイヤーの位置を更新します。
`clamp()`を使用して、プレイヤーが画面を離れないようにします。
値をクランプすることは特定の範囲に制限することを意味します。

```godotengine
position += velocity * delta
position = position.clamp(Vector2.ZERO, screen_size)
```

> `delta`パラメータは、フレームの長さ - 前フレームの完了時間を参照します。
> そのため動きの処理はフレームレートの変動の影響を受けなくなります。

シーンを実行してプレイヤーが全方向に移動できたら成功です。

## アニメーションの選択

プレイヤーを移動できるようになったので、AnimatedSprite2Dが再生するアニメーションの方向に合わせるようにします。
`walk`アニメーションでは右方向、左方向には`flip_h`プロパティを使用して水平に反転させて対応します。
`up`アニメーションも同様で、`flip_v`プロパティで反転させて下の動きを実装します。
では`_process()`関数を以下のようにします。

```godotengine
if velocity.x != 0:
	$AnimatedSprite2D.animation = "walk"
	$AnimatedSprite2D.flip_v = false
	# See the note below about the following boolean assignment.
	$AnimatedSprite2D.flip_h = velocity.x < 0
elif velocity.y != 0:
	$AnimatedSprite2D.animation = "up"
	$AnimatedSprite2D.flip_v = velocity.y > 0
```

> 上記のコードはプログラマーがよく使用する略式記法です。
> 比較テストと論理値の代入を同時に行う方法は以下のコードです。
```godotengine
if velocity.x < 0:
	$AnimatedSprite2D.flip_h = true
else:
	$AnimatedSprite2D.flip_h = false
```

では一度シーンを動かしてみて動作を確認しておきましょう。

動きが正しければ、`_ready()`に以下のコードを追加して、プレイヤーがゲーム開始時に非表示になるようにします。

```godotengine
hide()
```

## 当たり判定の準備

プレイヤーには敵に攻撃されたことを検知してもらいたいですが、まだ敵を作っていません！
でも大丈夫。Godotのシグナル機能を使って動作させます。

スクリプトの先頭に以下のコードを追加します。

```godotengine
signal hit
```

これは`hit`というカスタムシグナルを定義するもので、プレイヤーが敵と衝突した際にこのシグナルを送信します。
衝突の検出にはArea2Dを使用します。
プレイヤーノードを選択し、インスペクタのシグナルをクリックすると、送信可能なシグナルのリストが表示されます。

このリストには`hit`シグナルも存在します。
敵はRigidBody2Dノードになるため`body_entered(body: Node2D)`シグナルが必要です。
このシグナルは、本体がプレイヤーに接触した時に発信されます。
「接続」をクリックすると「メソッドにシグナルを接続」が出てきます。

Godotが自動生成した関数のコードの左側に緑のアイコンがあります。
これはシグナルがこの関数に接続していることを示しています。

続いて関数に次のコードを追加します。

```godotengine
func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
```

敵がプレイヤーに当たるたびにシグナルを発信します。
1度シグナルを発したらプレイヤーの衝突を無効にして、`hit`シグナルを複数回トリガーしないようにしたいです。

最後に新しいゲームの開始時にプレイヤーを初期化するための関数を追加します。

```godotengine
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false```
