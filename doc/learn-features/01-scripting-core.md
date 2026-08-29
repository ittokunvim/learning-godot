# コア機能

> 参考：https://docs.godotengine.org/ja/4.x/tutorials/scripting/index.html#toc-scripting-core-features


いくつかの機能はエンジン固有であり、サポートされているすべての言語で利用できます。
`GDScript, C#`や他の言語でコードを作成する場合でも、十分役立ちます。

## GodotAPIリファレンスの読み方

API（アプリケーション・プログラミング・インターフェース）とは、Godotがユーザーに提供する機能の一覧です。
これには、どのようなクラスが存在するか、それらが互いにどのように関連しているか、どのような機能を持っているか、そしてそれらをどのように使用するかの概要がまとめられています。

### 継承

各ファイルの先頭には、クラスの名前が表示されます。

「Inherits」セクションには、現在のクラスが継承している各クラスが一覧表示されます。
ここでは、CanvasItemはNodeを継承し、NodeはObjectを継承しています。

「Inherited By」セクションには、現在のクラスを直接継承している各クラスが一覧表示されます。
ここでは、ControlとNode2Dの両方がCanvasItemを継承しています。

### 説明

説明には主に以下のようなことが書かれています。

- クラスの動作の詳細。
- 一般的なユースケースのコードサンプル。
- クラスの各メソッドに共通する使用方法の詳細。
- 必要な依存関係や設定に関する注意事項。
- Godot API の他の関連部分へのリンク。

### クラスの各メソッドに共通する使用方法の詳細

NOTIFICATION_* 定数の説明には、どのエンジンイベントが通知をトリガーするかが記載されています。

### プロパティの説明

Godot APIのすべてのプロパティには、セッター関数とゲッター関数のペアが紐付けられています。
どちらを使用しても同じ結果が得られます。

その下には、そのプロパティのデータが何を表しているか、その使用例、および/または変更による影響についての詳細な概要が記載されています。
これには、コードサンプルや Godot API の関連部分へのリンクが含まれる場合があります。

> メソッド名やCallableを何かにバインドする必要がある場合、セッターやゲッターの名前を知っておくと便利です。

## デバッグ

Godotには、バグの追跡、実行時のゲームの検査、メトリックの監視、パフォーマンスの測定を行うデバッガーとプロファイラーが付属しています。
また、実行中のゲーム内のコリジョンボックスとナビゲーションポリゴンを視覚化するオプションも提供します。

### 出力パネル

メッセージには4つのカテゴリがあります。

| name    | color  | description                      | method                |
| ------- | ------ | -------------------------------- | --------------------- |
| Log     | 白、黒 | 標準的なメッセージ               | print(), print_rich() |
| Error   | 赤色   | 何らかの失敗を示したメッセージ   | push_error()          |
| Warning | 黄色   | 重要な情報を報告するメッセージ   | push_warning()        |
| Editor  | 灰色   | エディタから出力されるメッセージ | none                  |

### デバッガーパネル

パネルには主にスタックトレース、エラー、プロファイラー、があります。

スタックトレースは、ブレークポイントを使用したときに使うもので、コードの追跡ができます。

エラーは、ゲーム実行中のエラーと警告のメッセージが出力されます。

プロファイラーは、プロジェクト実行中にどのようなコードが実行されているかを見ます。
そしてそれがパフォーマンスにどのような影響を与えているかを確認します。

## アイドル、物理処理

Godotには2つの仮想メソッド：`Node._process(), Node._physics_process()`がNodeクラスに用意されています。

また以下の2つの処理が用意されています。

- アイドル処理：ノードをマイフレーム更新するようなコードを可能な限り頻繁に実行する。
- 物理処理：1秒間に60回実行される。これはゲームの実際のフレームレートとは無関係で実行される関数。

それぞれアイドル処理をしたければ`Node._process()`、物理処理がしたければ`Node._physics_process()`を使います。

パフォーマンスを重視したい場合は`_process()`、衝突判定やキャラクターの制御などの各物理ステップが必要なときは`_physics_process()`を使います。

また2つの関数の`delta`パラメーターはその関数が前回呼び出されてからの経過時間（秒）が格納されます。

## グループ

Godotのグループは他のソフトウェアのタグと同じような機能です。
ノードは複数のグループへ追加できます。
次にコードではSceneTreeを使用して以下のことを行うことができます。

- グループのノードのリストを取得。
- グループのノードのメソッドを呼び出し。
- グループのノードへシグナルを送信

これは大規模なシーンを整理し、コードを分離するのに便利な機能です。

グループを追加するには右側のドックでグループタブに移動して行います。
またスクリプトからグループを管理することもできます。

```godotengine
func _ready():
	add_to_group("guards")
```

ユーズケースとして、潜入ゲームを作成しているとします。
敵がプレイヤーを発見したら、すべての警備員とロボットが警戒する必要があります。

以下の例では`SceneTree.call_group()`を使用して、プレイヤーが発見されたことをすべての敵にアラートします。

```godotengine
func _on_player_spotted():
	get_tree().call_group("guards", "enter_alert_mode")
```

上記のコードでは、グループ`guards`の全てのメンバーに対して関数`enter_alert_mode`を呼び出します。

`guards`グループ内のリストを配列として取得するには以下のようにします。

```godotengine
var guards = get_tree().get_nodes_in_group("guards")
```

SceneTreeクラスには、シーン、ノード階層、グループとの対話など、多くの便利なメソッドを提供します。
シーンを簡単に切り替えたり、リロード、ゲーム終了、一時停止もできます。
まだまだ他にも面白いシグナルがあるので時間があれば見て良いかもしれません。

> SceneTree: https://docs.godotengine.org/ja/4.x/classes/class_scenetree.html#class-scenetree

## ノードとシーンインスタンス

ノードへの参照を取得するには`Node.get_node()`メソッドを呼び出します。

例えば以下のようなシーンツリーから、`Sprinte2D, Camera2D`ノードを参照するにはこのように書きます。

```godotengine
# - Player
#     - Camera2D
#     - Sprite2D
#     - CollisionShape2D

var sprite2d
var camera2d

func _ready():
	sprite2d = get_node("Sprite2D")
	camera2d = get_node("Camera2D")
```

ノードは型ではなく名前を使用して取得を行います。
例えば`Sprite2D`が`Character`という名前にしていた場合、`get_node("Character")`とします。

あとは参照したいノードが1つ下の階層にある場合、ファイルパスのように指定を行います。

```godotengine
get_node("ShieldBar/AnimationPlayer")
```

前もって参照するノードを変数に定義する方法「シンタックスシュガー」というのもあります。

```godotengine
@onready var sprite2d = get_node("Sprite2D")

@onready var sprite2d = $Sprite2D
@onready var animation_player = $ShieldBar/AnimationPlayer
```

コードからノードを作成するには、他のクラスベースのデータ型と同様に`new()`メソッドを呼び出します。

```godotengine
var sprite2d

func _ready():
	sprite2d = Sprite2D.new() # Create a new Sprite2D.
	add_child(sprite2d) # Add it as a child of this node.
```

ノードを削除してメモリを解放するには`queue_free()`メソッドを呼び出します。
実行するとノードの処理が完了した後、ノードが削除キューに入れられます。
削除キューに入れられたノードは現在のフレームの最後に実際に削除されます。
その時点でエンジンはシーンからノードを削除し、メモリ内のオブジェクトを解放します。

別の方法に`free()`を呼び出してノードを即座に破棄することもできます。
この場合は即座に`null`となるため注意が必要です。
特別なことがない場合は`queue_free()`がおすすめです。

シーンは必要なだけ複製を作成できるテンプレートです。
この操作はインスタンスかと呼ばれ、コードからの実行は次の2つの順序で行われます。

1. ローカルドライブからシーンをロード。
2. ロードされた`PackedScene`リソースのインスタンスを作成。

```godotengine
var scene = load("res://my_scene.tscn")
```

シーンをプリロードすると、ロード操作は実行時ではなくコンパイラがスクリプトを読み取る時に実行されます。
これによりユーザーエクスペリエンスが向上します。

```godotengine
var scene = preload("res://my_scene.tscn")
```

この時点では`scene`はまだノードではなくパックされたシーンのリソースです。
実際のノードを作成するには`PackedScene.instantiate()`関数を呼び出します。

```godotengine
var instance = scene.instantiate()
add_child(instance)
```

上記の2段階のプロセスの利点は、パックされたシーンをロードしたままにして、その場で新しいインスタンスを作成できることです。
例えば複数の敵や弾丸を素早くインスタンス化します。

## オーバーライド可能な関数

GodotのNodeクラスはフレーム、シーンツリーに入った時などの特定のイベントごとにノードを更新するオーバーライドできる仮想関数を提供します。

クラスのコンストラクターの他に`_enter_tree(), _ready()`という2つの関数を使用すると、ノードの初期化および取得ができます。

ノードはシーンツリーに入るとアクティブになり、エンジンは`_enter_tree()`メソッドを呼び出します。
これはシーンツリーへのノードの削除と再追加が可能なため、この関数はノードのライフタイムを通して複数回呼び出される可能性があります。

しかしほとんどの場合`_ready()`が使用されます。
この関数はノードの存続期間中に`_enter_tree()`の後に1度だけ呼び出されます。
そのため全ての子が最初のシーンツリーに入っていることを保証するので、安全に`get_node()`呼び出すことができるのです。

もう1つの関連するコールバックは`_exit_tree()`です。
これはノードがシーンツリーから出るたびにエンジンによって呼び出されます。
これは`Node.remove_child()`を呼び出した時や、ノードを解放した時です。

仮想関数`_process(), _physics_process()`はそれぞれノードをフレーム毎、物理フレーム毎に更新することができます。

さらに重要な`Node._unhandled_input(), Node._input()`コールバック関数です。
これらはここの入力イベントを受信して処理するために使用されます。
`_unhandled_input()`メソッドは`_input()`コールバックやまだ処理されていないキーの押下、クリックなどを受信します。
これはゲームプレイの入力全般に使用されます。
`_input()`コールバックは`_unhandled_input()`が取得する前に入力イベントをインターセプトして処理します。

他にも以下のような仮想関数があります。

```godotengine
Node._get_configuration_warning()
CanvasItem._draw()
Control._gui_input()
```

## クロスランゲージでのスクリプト作成

Godotでは必要に応じてスクリプト言語を組み合わせて使用することができます。

GDScriptからC#を使用する場合、そこまで大変ではありません。
注意点として`cs`スクリプトを作成する場合、Godotが使用するクラスは`.cs`ファイル自体と同じ名前のクラスである必要があります。

## スクリプトテンプレートの作成

Godotは新しいスクリプトを作成するときにテンプレートを指定することができます。
`macOS`の場合`$HOME/Library/Application Support/Godot/script_templates/`にあります。
またエディター、エディターのデータ・設定フォルダーを開くから見ることができます。

## 式の評価

Godotは式を評価するExpressionクラスを提供します。

- `(2 + 4) * 16 / 4.0`のような数式
- `true, false`のようなブール式
- `deg_to_rad(90)`のような組み込みメソッド
- `update_health()`などのユーザースクリプトに対するメソッド呼び出し

使い方は以下の通り

```godotengine
var expression = Expression.new()
expression.parse("20 + 10 * 2 - 5 / 2.0")
var result = expression.execute()
print(result) # 37.5
```

実用的なコード例は以下の通り。

```godotengine
const DAYS_IN_YEAR = 365
var script_member_variable = 1000


func _ready():
	evaluate("true && false")
	evaluate("!(a && b)", ["a", "b"], [true, false])

	evaluate("2 + 2")
	evaluate("x + y", ["x", "y"], [60, 100])

	evaluate("deg_to_rad(90)")

	# ユーザースクリプトの呼び出し
	evaluate("call_me() + DAYS_IN_YEAR + script_member_variable")
	evaluate("call_me(42)")
	evaluate("call_me('some string')")


func evaluate(command, variable_names = [], variable_values = []) -> void:
	var expression = Expression.new()
	var error = expression.parse(command, variable_names)
	if error != OK:
		push_error(expression.get_error_text())
		return

	var result = expression.execute(variable_values, self)

	if not expression.has_execute_failed():
		print(str(result))


func call_me(argument = null):
	print("\nYou called 'call_me()' in the expression text.")
	if argument:
		print("Argument passed: %s" % argument)

	# The method's return value is also the expression's return value.
	return 0
```

## シグナルによるインスタンス化

シグナルはゲームオブジェクトを分離する方法を提供し、ノードの固定配置を強制することを回避できます。
シグナルに必要なものは`get_parent()`を使用して自分自身を見つけた時です。
ノードの親を直接参照するということは、そのノードをシーンツリー内の別の場所に簡単には移動できないということです。
これは実行時にオブジェクトをインスタンス化し、実行中のシーンツリーの任意の場所に配置する場合に問題となります。

### 発射処理の例

マウスに向かって回転して球を打つことができるプレイヤーと考えてみましょう。
クリックされるたびにプレイヤーの位置に弾丸のインスタンスが作成されます。

```godotengine
extends Area2D

var velocity = Vector2.RIGHT

func _physics_process(delta):
	position += velocity * delta
```

しかし弾丸がプレイヤーの子として追加された場合、プレイヤーが回転すると弾丸もアタッチされたままになります。

代わりに弾丸はプレイヤーの動きから独立する必要があります。
発射されたら弾丸は直線で移動し続ける必要があり、プレイヤーは弾丸に影響を与えないようにします。
つまりプレイヤーの子に追加するのではなく、メインの方に子として追加する方が理にかなっています。

```godotengine
var bullet_instance = Bullet.instantiate()
get_parent().add_child(bullet_instance)
```

しかしこれには別の問題があります。
プレイヤーシーンをテストすると弾丸がアクセスする親ノードがないため、確認時にクラッシュします。
またメインシーンのノード構造を変更する場合、プレイヤーの親が弾丸を受け取る適切なノードではなくなる可能性があります。

解決策はプレイヤーから弾丸を放出するシグナルを使用することです。
プレイヤーはその後、弾丸がどうなるのか知る必要はありません。
シグナルに接続されているノードは弾丸を受信し、弾丸を発生させるために適切なアクションを実行できます。

```godotengine
extends Sprite2D

signal shoot(bullet, direction, location)

var Bullet = preload("res://bullet.tscn")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shoot.emit(Bullet, rotation, position)

func _process(delta):
	look_at(get_global_mouse_position())
```

メインシーンでプレイヤーのシグナルを接続します。

```godotengine
func _on_player_shoot(Bullet, direction, location):
	var spawned_bullet = Bullet.instantiate()
	add_child(spawned_bullet)
	spawned_bullet.rotation = direction
	spawned_bullet.position = location
	spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
```

## ゲームのプロセスのポーズ

ほとんどのゲームでは休憩を取ったりオプションを変更したり、何か別のことをするためにゲームを中断できると良いです。
何を中断できるかをきめ細かく制御することは大変なため、Godotにはポーズのためのシンプルなフレームワークが提供されています。

ゲームをポーズするにはポーズ状態を設定する必要があります。
これはSceneTree.pausedプロパティに`true`をセットすることで行われます。

これを行うと2つのことが起こります。
1つが`2D, 3D`物理演算が全てのノード停止、2つ目が特定のノードの動作がプロセスモードに応じて停止または開始します。

> 物理サーバーはゲームのポーズ中に`set_active`メソッドでアクティブにすることが可能です。

プロセスモードはGodotの各ノードがどのように処理するかを定義する機能です。
インスペクタのNodeプロパティ内にあります。

またコードから変更も可能です。

```godotengine
func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
```

各モードに応じたノードの振る舞いは以下の通りです。

`Inherit`: 親や祖先などの状態に応じたプロセス。（デフォルト）
`Pausable`: ゲームが一時停止されていない場合のみ処理を行う。
`WhenPaused`: ゲームがポーズされている場合のみ処理する。
`Always`: 常にノードを処理する。
`Disabled`: 常に処理されない。

`_process, _physics_process, _input, _input_event`関数は呼び出されません。
ただし関数のスクリプトが現在処理されていないノードにアタッチされている場合、シグナルで接続されている関数は実行される。

アニメーション、オーディオ、パーティクルもポーズします。

物理演算もポーズします。
また`set_active`メソッドを使用してアクティブにすることができます。

ポーズの例としては、まず閉じるボタンを作成し、メニューのルートノードのプロセスモードを`WhenPaused`に設定し、ボタンを非表示にする。
こうするとゲームが一時停止された時に、メニュー内の全てのノードが処理を開始します。

スクリプトをメニューのルートノードにアタッチし、
前に作成したポーズボタンをスクリプト内の新しいメソッドに接続し、
そのメソッド内でゲームをポーズしてポーズメニューを表示します。

```godotengine
func _on_pause_button_pressed():
	get_tree().paused = true
	show()
```

最後にメニューの閉じるボタンをスクリプト内の新しいメソッドに接続します。
そのメソッド内でゲームのポーズを解除し、ポーズメニューを非表示にします。

```godotengine
func _on_close_button_pressed():
	hide()
	get_tree().paused = false
```

## ファイルシステム

ファイルシステムはアセットの保存方法とアクセス方法を管理します。
また適切に設計されたファイルシステムにより、複数の開発者が共同作業中に同じソースファイルとアセットを編集できます。
Godotは全てのアセットをファイルシステムのファイルとして保存します。

ファイルシステムはディスク上にリソースを格納します。
スクリプトからシーンPNGに至るまであらゆるものがエンジンのリソースとなります。
ディスク上の他のリソースを参照するプロパティがリソースにある場合でもリソースのパスも含まれます。
リソースに組み込みのサブリソースがある場合、そのリソースはバンドルされた全てのサブリソースとともに1つのファイルに保存されます。
例えばフォントは多くの場合、フォントテクスチャと一緒にバンドルされています。

Godotファイルシステムはメタデータファイルを回避します。
Godotは`SubVersion, Git, Mercurial`などと一緒に作業できるように最善を尽くしています。

`project.godot`ファイルはプロジェクト記述ファイルであり、これが置かれた場所にルートが設定されます。
このファイルには`win.ini`形式を使用したプロジェクト構成がプレーンテキストで含まれています。
からの`project.godot`出会っても、空白のプロジェクトの基本的な定義として機能します。

リソースにアクセスする際、ホストOSファイルシステムのレイアウトを使用すると、面倒で移植性に欠けることがあります。
この問題を解決するために`res://`が作成されました。
`res://`は常にプロジェクトルートを指します。
このファイルシステムはエディタからプロジェクトをローカルで実行する場合にのみ、読み書きが可能になります。
エクスポートする場合、異なるデバイスで実行する場合、読み取り専用隣書き込みは許可されなくなります。

ゲーム状態の保存やコンテンツのダウンロードなどのタスクには、ディスクへの書き込みが必要です。
このためエンジンには`user://`パスがあり、いつでも書き込みができます。
このパスはプロジェクトが実行されているOSによって異なります。

## リソース

チュートリアルでは主にNodeクラスについて紹介しました。
それと同じくらい重要なデータ型がResourceです。

Nodeは機能を提供します。
3Dモデルの表示、物理演算、UIなどです。
Resourceはデータの格納に使います。
リソース自身は何もしませんが、代わりにノードがデータの入ったリソースを使用します。

Godotがディスクから保存、読み取るものは全てリソースです。
シーン、画像、スクリプトなどが該当します。

また読み込みは一度きりです。
一度読み込んだらそれ以降はコピーを使用します。

ノードとリソースに関わらず、全てのオブジェクトは自身のプロパティをエクスポートできます。
プロパティには、`String, int, Vector2`など様々な種類がありますが、全てリソースになることができます。
つまりノードとリソースはいずれも他のリソースをプロパティとして持てます。

リソースを保存する方法は2つあります。

- シーンの外部、個別のファイルとしてディスクに保存。
- シーンの内部、使用する`.tscn, .scn`ファイル内に保存。

コードからリソースを読み込む方法は2つあります。
1つは`load()`関数を使います。

```godotengine
func _ready():
	# Godot loads the Resource when it reads this very line.
	var imported_resource = load("res://robi.png")
	$sprite.texture = imported_resource
```

シーンはPackedScene型のリソースとしてディスクに保存されます。
インスタンスを得るには`instaniate()`メソッドを使用する必要があります。

```godotengine
func _on_shoot():
		var bullet = preload("res://bullet.tscn").instantiate()
		add_child(bullet)
```

このメソッドはシーンの階層通りにノードを作成し、設定してからシーンのルートノードを返します。

この方法の利点は高速なことです。
新しい敵、弾丸、エフェクトなどをディスクから再読み込みすることなく作成できます。

リソースが使われなくなったら実動的に解放されます。
ほとんどの場合リソースはノードに格納されているので、ノードが解放したらリソースも解放されます。

またリソースをスクリプト化することもできます。
これには`JSON, CSV, TXT`ファイルなどの代替となるデータ構造を超える多くの明確な利点があります。

リソーススクリプト：
```godotengine
class_name BotStats
extends Resource

@export var health: int
@export var sub_resource: Resource
@export var strings: PackedStringArray

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_health = 0, p_sub_resource = null, p_strings = []):
	health = p_health
	sub_resource = p_sub_resource
	strings = p_strings
```

CharacterBody3Dスクリプト：
```godotengine
extends CharacterBody3D

@export var stats: Resource

func _ready():
	# Uses an implicit, duck-typed interface for any 'health'-compatible resources.
	if stats:
		stats.health = 10
		print(stats.health)
		# Prints "10"
```

## シングルトン（自動読み込み）

Godotのシーンシステムには欠点があります。
例えば複数のシーンで必要とされる情報を保持する方法がないです。
例えばプレイヤーのスコアやインベントリを保持することなど。

対応する方法もありますが制限もあります。

1つはマスターシーンを用意して、子供としてシーンをロードします。
しかしこの方法では各シーンを期待通りに個別に動作させることが難しくなります。

2つめが情報をディスクの`user://`にセーブし、必要な時にロードします。
しかしこの方法ではシーン切り替えごとにセーブとロードを行うことになり遅くなります。

シングルトンパターンは複数のシーン間で永続的な情報を保持するのに便利なツールです。
同じシーン、クラスを複数のシングルトンを使った再利用は名前が異なる限り可能です。

シングルトンを使うと、以下のようなオブジェクトを作ることができます。

- 現在の実行に関係なく、常にロードされる。
- プレイヤー情報のようなグローバル変数を保管できる。
- シーンの切り替えやシーン間の遷移を処理できる。

### 自動読み込み

自動読み込みを設定するとNodeを継承したシーンやスクリプトをロードすることができます。

シーンもしくはスクリプトを自動読み込みするには、プロジェクト設定、グローバル、自動読み込みに移動します。

ここに任意の数のシーンまたはスクリプトを追加できます。

```godotengine
PlayerVariables.health -= 10
```

### カスタムシーン・スイッチャー

このチュートリアルは自動読み込みを使ったシーンスイッチャーの構築方法を説明します。
基本的なシーンの切り替えは`SceneTree.change_scene_to_file()`メソッドが有効です。

はじめに以下のURLからテンプレートをダウンロードしGodotで開きます。

https://github.com/godotengine/godot-docs-project-starters/releases/download/latest-4.x/singleton_autoload_starter.zip

#### スクリプトを変更する

新しいスクリプト`global.gd`を作成します。
Nodeから継承するようにします。

次にスクリプトを自動読み込みリストに追加します。
プロジェクト設定、グローバル、自動読み込みを開き`global.gd`を入力します。
追加するときに名前を`Global`と名付けます。

これでスクリプトはプロジェクトのシーンを実行される時に毎回ロードされます。

次に以下のコードを`global.gd`に記述します。

```godotengine
extends Node

var current_scene = null

func _ready():
	var root = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)
```

次にシーンを遷移させるための関数をスクリプトに記述します。

```godotengine
func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
```

`Object.call_deferred()`は現在のシーンが完了してから実行されます。
なので現在のシーンが実行されている間に実行されません。

最後に2つのシーンのスクリプトに以下のコードを記述します。

```godotengine
# Add to 'scene_1.gd'.

func _on_button_pressed():
	Global.goto_scene("res://scene_2.tscn")


# Add to 'scene_2.gd'.

func _on_button_pressed():
	Global.goto_scene("res://scene_1.tscn")
```

プロジェクトを実行すると、ボタンを押すとシーンが切り替わります。

> シーンが小さい時には遷移はすぐに終わりますが、複雑な場合には時間がかかります。
> その場合バックグラウンド読み込みという機能があるのでそれを使います。
> 
> また読み込み時間内にローディング中画面を表示することもできます。

## シーンツリーの使用

ここまではノードの概念を中心に見てきました。
シーンはノードのコレクションで、シーンツリーに入るとそれはアクティブになります。

Godotの内部動作は、OSクラスがあってこれは開始時に実行される唯一のインスタンスです。
その後にドライバ、サーバー、スクリプト、シーンなどが読み込まれます。

初期化が完了したら、実行するためにOSにメインループを提供する必要があります。

ユーザープログラムまたはゲームはメインループで起動します。
このクラスは初期化、アイドル（フレーム同期コールバック）、固定（物理同期コールバック）、および入力などのメソッドがあります。
ここでの話は低レベルの処理であり、Godotがやってくれることです。

### シーンツリー

Godotは低レベルのミドルウェアの上に構築された高レベルのゲームエンジンです。

シーンシステムがゲームエンジンであり、OSやサーバーが低レベルのAPIに当たります。

シーンシステムは独自のメインループであるSceneTreeをOSに提供します。

SceneTreeクラスにはいくつかの重要な用途があるため、ある程度知っておいた方が良いです：

- ルートViewportが含まれており、シーンツリーの一部になるために子として追加される。
- グループの情報が含まれており、グループ内の全てのノードを呼び出すかリストを取得する手段がある。
- 一時停止、プロセスの終了などのグローバル状態に関する機能が含まれている。

ノードがシーンツリーの一部である場合、`Node.get_tree()`を呼び出すことでSceneTreeシングルトンを取得できます。

ルートビューポートは常にシーンの一番上にあります。
下記のコードで取得ができます。

```godotengine
get_tree().root
get_node("/root")
```

ノードがルートビューポートに直接、間接的に接続されるとシーンツリーの一部となります。
つまり`_enter_tree(), _ready(), _exit_tree()`のコールバックが取得されます。

ノードはシーンツリーに入るとアクティブになります。
処理、入力、2D3Dビジュアルの表示、通知の送受信、音楽の再生などに必要なものにアクセスできます。

Godotのほとんどのノードはツリー順序、つまりエディターで表示されるように上から下へ実行されます。

例外なのが`_ready()`関数で、各親ノードは子ノードが`_ready()`関数を呼び出した後に親ノードの`_ready()`関数を呼び出します。
簡単に言うと`_ready()`関数に関しては下から上へ実行されます。

### 現在のシーンの変更

シーンがロードされた後、このシーンを別のシーンに変更することがしばしば望まれます。

```godotengine
func _my_level_was_completed():
	get_tree().change_scene_to_file("res://levels/level2.tscn")
```

またファイルパスを使用する代わりに既製のPackedSceneリソースを使用することもできます。

```godotengine
var next_scene = preload("res://levels/level2.tscn")

func _my_level_was_completed():
	get_tree().change_scene_to_packed(next_scene)
```

これらはシーンを切り替える迅速で便利な方法ですが、新しいシーンが読み込まれて実行されるまでゲームが停止すると言う欠点があります。
ゲーム開発のある時点で、プログレスバー、アニメーションインジケータ、またはスレッドの読み込みを備えた、適切な読み込み画面を作成することをお勧めします。
これについてはシングルトン（自動読み込み）とバックグラウンド読み込みを使用して手動で行う必要があります。

## シーン固有ノード

`get_node()`を使用したノードの参照するコードは壊れやすい可能性があります。
もしノードの場所を移動するとスクリプトがそのノードを見つけられなくなるからです。

この場合特定のノードをシーン固有ノードに変更することで、ノードのパスが変更されるたびにスクリプトを更新しなくて済みます。

シーン固有ノードはシーンツリードックから作成できます。
コンテキストメニューから固有名でアクセスを選択し、シーンツリー内のノードの横に％記号が表示されたら成功です。

これでスクリプト内で固有ノードを使用できるようになります。
使い方は以下の通りです。

```godotengine
get_node("%RedButton").text = "Hello"
%RedButton.text = "Hello" # Shorter syntax
```

シーン固有ノードは同じシーン内のノードからのみ取得できます。
例として以下のようなシーンツリーがあったとします。

- Player
- Eyes
- Body
- Hand
    - Sword
        - Hilt
        - Blade

Playerスクリプトの場合。
- `get_node("%Eyes")` -> Eyes
- `get_node("%Hilt")` -> null

Swordスクリプトの場合。
- `get_node("%Eyes")` -> nul
- `get_node("%Hilt")` -> Hilt

以下のコードの場合。
- `get_node("Hnad/Sword").get_node("%Hilt")` -> Hilt
- `get_node("Hnad/Sword/%Hilt")` -> Hilt

シーン固有ノードはシーンをナビゲートするための便利なツールです。
ただし状況によっては他のテクニックの方が優れている場合もあります。

Groupを使用すると、配置に関係なく他のノードから特定のノードを見つけることができます。

Singletonはシーンに関係なく任意のノードから直接アクセスできるノードです。
これは一部のデータ、関数がグローバルに共有される場合に便利です。

Node.find_child()はパスではなく名前でノードを検索します。
シーン固有ノードににているが、特徴としてシーン内の深いところのノードも見つけることができます。
ただし速度に問題があります。

## ログ

Godotはデフォルトで`user://logs/godot.log`にログファイルを書き込みます。
保存場所の変更はプロジェクト設定の`debug/file_logging/log_path`から可能です。
