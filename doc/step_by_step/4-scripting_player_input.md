# プレイヤーの入力に対応する

参考：https://docs.godotengine.org/ja/4.x/getting_started/step_by_step/scripting_player_input.html

前回のレッスンを踏まえて、プレイヤーにコントロールを与えることについて見ていきましょう。

![プレイヤー操作で動くアイコン](images/scripting_first_script_moving_with_input.webp)

Godotでは、プレイヤーの入力を処理するために、主に2つのツールが用意されています。

- 組み込みの入力コールバック。
- Inputシングルトン

組み込みの入力コールバックは主に`_unhandled_input()`です。
これはプレイヤーがキーを押すたびに呼び出される仮想関数です。

シングルトンはグローバルにアクセス可能なオブジェクトです。
これは毎フレーム入力があるかどうかを確認するのに適したツールです。

ここではInputシングルトンを使用します。
これはプレイヤーがフレームごとに回転、移動するのかを知る必要があるからです。

回転させるために`direction`という新しい変数を定義します。
`_process()`関数に以下のコードを置き換えます。

```godotengine
+ var direction = 0
+ if Input.is_action_pressed("ui_left"):
+ 	direction = -1
+ if Input.is_action_pressed("ui_right"):
+ 	direction = 1

- rotation += angular_speed * delta
+ rotation += angular_speed * direction * delta
```

ローカル変数`direction`は、プレイヤーが曲がりたい方向を表す乗数です。
値が0ならプレイヤーがキーを押していないことを意味し、1なら右に、-1なら左に曲がることを意味します。

これらの値を生成するために、条件文とInputの使用を導入します。
GDScriptにおける条件文は、ifキーワードで始まり、コロンで終わります。
条件とはキーワードと行末のコロンとの間に書かれた式のことです。

このフレームでキーが押されたか確認するために`Input.is_action_pressed()`を呼び出します。
このメソッドは入力アクションを表す文字列を受け取り、押された場合は`true`、それ以外は`false`を返します。

上記で使用した2つのアクション、`ui_left, ui_right`はGodotプロジェクトにあらかじめ定義されています。
それぞれプレイヤーがキーボードでキーを押した時に起動します。

最後に`direction`を`rotation`の更新時の乗数として使用します。

そして以下のコードをコメントアウトします。

```godotengine
#var velocity = Vector2.UP.rotated(rotation) * speed

#position += velocity * delta
```

このコードでシーンを実行すると、キーを押した時にアイコンが回転するはずです。

## 上ボタンを押すと動く

キーを押した時だけ動くようにするには、速度を計算するコードを修正する必要があります。
コメントアウトを解除して`velocity`の行を以下のコードに置き換えます。

```godotengine
- #var velocity = Vector2.UP.rotated(rotation) * speed
+ var velocity = Vector2.ZERO
+ if Input.is_action_pressed("ui_up"):
+ 	velocity = Vector2.UP.rotated(rotation) * speed

position += velocity * delta
```

まずは`velocity`を`Vector2.ZERO`という値で初期化します。
そしてプレイヤーが上キーを押すと、`velocity`の値が更新され、アイコンが前に移動するようになります。

## 完全なスクリプト

```godotengine:sprite_2d.gd
extends Sprite2D

var speed = 400
var angular_speed = PI


func _process(delta):
	var direction = 0
	if Input.is_action_pressed("ui_left"):
		direction = -1
	if Input.is_action_pressed("ui_right"):
		direction = 1

	rotation += angular_speed * direction * delta

	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation) * speed

	position += velocity * delta
```

## まとめ

Godotの全てのスクリプトはクラスを表し、エンジンの組み込みクラスの1つを拡張します。
クラスが継承するノードタイプにより、`rotation, position`などのプロパティにアクセスできるようになります。

GDScriptでは、ファイルの先頭に置いた変数は、クラスのプロパティでメンバー変数とも呼ばれます。
また、変数以外にも関数を定義できますが、これはほぼクラスのメソッドになります。

Godotは、クラスとエンジンを接続するために定義可能はいくつかの仮想関数を提供します。
`_process()`はフレームごとにノードに変更を適用し、`_unhandled_input()`はユーザーから入力イベントを受け取ります。

Inputシングルトンを使用すると、コード内のどこからでもプレイヤーの入力に応答することができます。
特に、_process()ループ内でこれを利用することになります。

次のレッスン「シグナルの使用」では、トリガーとスクリプトとノードの関係を構築する方法を学びます。
