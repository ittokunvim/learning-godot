# プログラムでプレイヤーを動かす

> 参考：https://docs.godotengine.org/ja/4.x/getting_started/first_3d_game/03.player_movement_code.html

いよいよコーディングです。
前のパートで作成した入力アクションでキャラクタを動かしていきます。

ではPlayerノードからスクリプトをアタッチします。
そして移動速度(speed)、落下加速度(gravity)、速度(velocity)を定義していきます。

```godotengine
extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO
```

これらは移動する物体に共通するプロパティです。
`target_velocity`は速度と方向を組み合わせた`3Dベクトル`です。
ここではフレーム間で値を更新して再利用したいのでプロパティとして定義しています。

> 距離はM単位なので、2Dコードとは値が異なります。
> 2Dでは1000単位（ピクセル）は画面の幅の半分しか相当しませんが、3Dでは1kmになります。

それでは移動をコーディングしていきます。
グローバルな`Input`オブジェクトを使用し、`_physics_process()`内で入力方向ベクトルを計算します。

```godotengine
func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
```

ここでは`_process()`の代わりに`_physics_process()`を使用して計算を行います。
これは運動学や剛体の移動などの物理関連のコード専用に設計されています。
これは一定の時間感覚でノードを更新します。

まず`direction`変数を`Vector3.ZERO`で初期化します。
次にプレイヤーが`move_*`の入力があるか確認し、ベクトルの`x, z`を更新します。
これらの成分は地平面の軸に相当します。

この4つの条件は8つの可能性と8つの可能な方向を与えます。

例えば、プレイヤーが`WD`キーを両方押した場合、ベクトルの長さは`1.4`程度になります。
しかし1つのキーを押した場合は`1`の長さになります。
この差異を無くしたいので、`normarized()`メソッドを呼び出します。

```godotengine
func _physics_process(delta):
	#...

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)
```

ここでは方向が0より大きい長さを持つ場合、ベクトルを正規化(normalize)します。
`$Pivot`が向いている方向を、`direction`方向を向く`Basis`を生成することで計算します。

次に速度(velocity)を更新します。
地面での速度と落下速度を別々に計算する必要があります。
`_physics_process()`に以下のコードを記述します。

```godotengine
func _physics_process(delta):
	#...
	if direction != Vector3.ZERO:
		#...

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
```

`CharacterBody3D.is_on_floor()`関数はオブジェクトが床と接触しているフレームで`true`を返します。
そのためPlayerが空中にいる間だけ重力を適用すれば良いのです。

垂直方向の速度については、マイフレーム落下加速度にデルタタイムを掛けたものを引きます。
このコードでキャラクタは床に乗るかは接触していない間はマイフレーム落下するようになります。

物理エンジンは移動、衝突が起こった場合のみ、特定のフレームにおける壁、床、他の物体との相互作用を検出することができます。
あとでそのプロパティを使用してジャンプをコーディングします。

`Character3D.move_and_slide()`ではキャラクタをスムーズに動かすことができます。
例え動きの途中に壁にぶつかっても、エンジンがスムーズな動きにしようとします。
これはCharacterBody3Dの`velocity`の値を使用します。

いかがこれまでに記述したコードです。

```godotengine
extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO


func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
```

## プレイヤーの動きをテスト

Mainのシーンにプレイヤーをおいてテストします。
そのためにプレイヤーをインスタンス化し、カメラを追加する必要があります。
2Dとは異なり、3Dではビューポートにカメラがない場合は何も見えません。

まずはMainシーンを開きます。
そしてPlayerをインスタンス化するには、Mainノードを選択し「子シーンをインスタンス化」を選択します。

### カメラを追加する

次にカメラを追加します。
PlayerのPivotのように基本的なリグを作成します。
Mainノードを選択し「子ノードを追加」を選択します。
新しいMarker3Dを作成し、名前をCameraPivotとします。
そしてCameraPivotの子ノードにCamera3Dを追加します。
シーンツリーは以下の通りになります。

- Main
    - Ground
        - CollisionShape3D
        - MeshInstance3D
    - DirectionLight3D
    - Player
    - CameraPivot
        - Camera3D

Cameraを選択するとプレビューチェックボックスが現れ、ゲーム内のカメラの投影をプレビューすることが可能です。

ここではPivotを使用して、カメラを回転させることにします。
まず3Dビューを分割してシーンを自由に移動できるようにし、カメラが見ているものを確認できるようにしましょう。

ビューポートの上のツールバーで、2ビューポートを選択します。

カメラプレビューをオンにし、Camera3DをZ軸方向に`19`ユニットほど移動します。

ここでCameraPivotを選択し、X軸の周りで`-45`度回転させます。
カメラがクレーンに取り付けられているように動くと思います。

ではシーンを実行して、キーを入力しプレイヤーが動くか見てみましょう。

透視投影(Perspective)を使用しているため、キャラクタの周囲の何もない空間が見えています。
このゲームではゲームプレイエリアをより適切に枠に収め、プレイヤーが距離を読みやすくするために、
平行投影(Orthographic)を使用します。

Camera3Dを選択し、インスペクター、Projectionを`Orthognal`、Sizeを`19`に設定します。
これでキャラクタはより平坦に見え、地面が背景を埋めるようになるはずです。

> Godot4でおるそグラフィックカメラ（平行に投影するカメラ）を使用する場合、ディレクショナルライト（ライト1灯でシーン全体を照らすライト）
> のシャドウの品質はカメラのFar値に依存します。
> Far値が高いほどカメラはより遠くを見ることができますが影のレンダリングがより長い距離をカバーすることになるため、影の品質が低下します。
> 平行投影に切り替えたあと、ディレクショナルシャドウがぼやけて見える場合、カメラのFarプロパティを`100`などの低い値に下げてください。
> Farプロパティを低く設定しすぎると、遠くのオブジェクトが表示されなくなるため、適切な値を設定します。

シーンを実行してみましょう。
8方向移動ができ、床がすり抜けなければ成功です！

最終的にプレイヤーの動きとビューの両方が整いました。
次はモンスターを作成していきます。
