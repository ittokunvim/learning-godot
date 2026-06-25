# シグナルの使用

> 参考：https://docs.godotengine.org/ja/4.x/getting_started/step_by_step/signals.html

このレッスンでは、シグナルを見ていきます。
これらはボタンが押された、などの特定のことが起こった時にノードが発信するメッセージです。
他のノードはシグナルに接続し、イベントが発生した時に関数を呼び出すことができます。

シグナルはGodotに組み込まれた委任メカニズムで、ゲームオブジェクトの変更に反応する際に、
それらを相互参照させることなく反応できるようにするものです。
シグナルを使うと、結合度を制限し、コードの柔軟性を保つことができます。

例えば、画面上にプレイヤーの体力を表すライフバーがあるとします。
プレイヤーがダメージを受けたり、回復したりした場合に、その変化をバーに繁栄したいと考えます。
この実装にGodotではシグナルを使用します。

メソッドと同様に、シグナルはGodot4.0以降の最重要な型です。
つまり文字列として渡す必要がなく、メソッドの引数として直接渡すことができるという意味であり、
オートコンプリートの向上と、エラーの抑制につながります。

次のパートではシグナルを使って、Godotアイコンがボタンを押すことで動いたり止まったりするようにします。

> GDScriptの命名規則は、クラスは`PascalCaseを`、変数と関数は`snake_case`、定数は`All_CAPS`を使用します。

## シーンの設定

ゲームにボタンを追加するために`sprite_2d.tscn`に新しいシーンを作成します。

1. 新しい`2D Scene`を作成
2. `sprite_2d.tscn`に作成したシーンをドロップしインスタンス化を行う
3. `Add Child Node`を選択し、`Button`ノードを追加
4. サイズを変更して、Godotアイコンの近くへ動かし、Godotアイコンの近くへ動かす

## エディタ内でシグナルを接続する

ここではButtonの`pressed`シグナルをSprite2Dに接続し、その動きを切り替える新しい関数を呼び出します。
ではSprite2Dノードにスクリプトをアタッチしていきましょう。

Buttonノードを選択し、右側のドックにあるInspectorの隣のSignalsを選択します。
そして`pressed`シグナルを選ぶと、ノード接続ウィンドウが開きます。

そこでSprite2Dノードにシグナルを接続でき、ノードは`receiver`メソッドを必要とします。
これはButtonがシグナルを発信した時にGodotが呼び出す関数です。
エディタはこの関数を自動生成し、規約として名前を`_on_ノード名_シグナル名`となります。

Connectボタンをクリックしてシグナルの接続を完了し、スクリプトワークスペースに移動します。

Sprite2Dが動くのは、`_process()`関数内のコードのおかげです。
Godotは処理のオン・オフを切り替えるメソッド：`Node.set_process()`を提供しています。
Nodeクラスの別のメソッドである`is_processing()`は、アイドル処理が有効であれば`true`を返します。

```godotengine
func _on_button_pressed():
	set_process(not is_processing())
```

この関数はボタンを押した時に、処理を切り替えてアイコンの動作のオン・オフを切り替えます。

試す前に少しリファクタリングを行います。
以下のコードのように記述し、ボタンを押した時に、アイコンが開始、停止したら成功です。

```godotengine:sprite_2d.gd
extends Sprite2D

var speed = 400
var angular_speed = PI


func _process(delta):
	rotation += angular_speed * delta
	var velocity = Vector2.UP.rotated(rotation) * speed
	position += velocity * delta


func _on_button_pressed():
	set_process(not is_processing())
```

## コード経由でシグナルを接続する

エディタを使用する代わりに、コードを開始てシグナルを接続することができます。
これはスクリプトの中でノードを作成したり、シーンをインスタンス化する時に必要です。

ここでTimerノードという別のノードを使って見ましょう。
これはスキルのクールダウン時間や武器のリロードなどを実装するのに便利です。

シーンドックでSprite2DノードにTimerノードを追加します。

追加したら、TimerのインスペクタードックでAutoStartをオンにします。

ノードをコードで接続するには、2つの操作が必要です。

1. Sprite2DからTimerへの参照を取得します。
2. Timerの`timeout`シグナルで、`connect()`メソッドを呼び出します。

シーンがインスタンス化された時にシグナルを接続する場合は、`Node._ready()`ビルトイン関数を使用します。
この関数はノードが完全にインスタンス化されるとエンジンから自動的に呼び出されます。

現在のノードに関連するノードの参照を取得するには、`Node.get_node()`というメソッドを使用します。
この参照は変数に格納することができます。

```godotengine
func _ready():
	var timer = get_node("Timer")
```

関数`get_node()`は、Sprite2Dの子を調べて取得します。
例えば、Timerノードの名前を`BlinkingTimer`にした場合、`get_node("BlinkingTimer")`で値を取得できます。

これで`_ready()`関数内でTimerをSprite2Dに接続することができます。

```godotengine
func _ready():
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)
```

ここではTimerの`timeout`シグナルを、スクリプトが接続されているノードに接続します。
シグナルを発信したら、`_on_timer_timeout()`を呼び出したいのでこれを定義します。

```godotengine
func _on_timer_timeout():
	visible = not visible
```

この2Dシーンを実行すると、スプライトが1秒感覚で点滅します。

## 完全なスクリプト

以下が`sprite_2d.gd`の完成したファイルです。

```godotengine
extends Sprite2D

var speed = 400
var angular_speed = PI


func _ready():
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)


func _process(delta):
	rotation += angular_speed * delta
	var velocity = Vector2.UP.rotated(rotation) * speed
	position += velocity * delta


func _on_button_pressed():
	set_process(not is_processing())


func _on_timer_timeout():
	visible = not visible
```

## カスタムシグナル

スクリプトでカスタムシグナルを定義することができます。
例えばプレイヤーの体力が0になった時にゲームオーバー画面を表示するとします。
そのためには体力が0になった時に`died`という名前のシグナルを定義することができます。

```godotengine
extends Node2D

signal health_depleted

var health = 10
```

スクリプト内でシグナルを発信するには、`emit()`を呼び出します。

```godotengine
func take_damage(amount):
    health -= amount
    if health <= 0:
        health_depleted.emit()
```

シグナルはオプションで1つ以上の引数を宣言できます。

```godotengine
extends Node2D

signal health_changed(old_value, new_value)

var health = 10
```

シグナルと一緒に出力するには、`emit()`関数に追加の引数として値を追加します。

```godotengine
func take_damage(amount):
	var old_health = health
	health -= amount
	health_changed.emit(old_health, health)
```

## まとめ

Godotでは、何か特定のことが起こるとシグナルを発します。
他のノードは個々のシグナルに接続し、選択されたイベントに反応することができます。

シグナルには多くの用途があります。
ゲームに出入りするノード、衝突、領域に出入りするキャラクタ、サイズが変化するUIなどです。

例えば、コインの見た目をしたArea2Dがあります。
これはプレイヤーの物理ボディが衝突形状に入るたびに`body_entered`シグナルを発します。
これによりそれを収集したタイミングを知ることができます。

次のセクションでは、完全な2Dゲームを作成し、これまで学んだことを実践します。
