# モンスターを踏みつける

> 参考：https://docs.godotengine.org/ja/4.x/getting_started/first_3d_game/06.jump_and_squash.html

このパートでは、モンスターをジャンプして踏みつける機能を追加します。
また次のレッスンでは、モンスターが地面でプレイヤーにあたった時にプレイヤーが死亡するようにします。

まず物理的な相互作用に関連する幾つかの設定を変更します。
物理レイヤーの世界に入りましょう！

## 物理的相互作用のコントロール

物理ボディには、レイヤーとマスクという2つの補完的なプロパティが用意されています。
レイヤーはオブジェクトがどの物理レイヤー上に存在するかを定義します。

マスクは、物体が反応して検出するレイヤーを制御します。
これは衝突検出に影響を与え、2つの物体を相互作用させたい場合、一方のマスクが一方のレイヤーに対応している必要があります。

重要なポイントは、レイヤーとマスクを使用して物理的な相互作用をフィルタリングし、パフォーマンスを制御し、コード内で追加の条件を不要にできることです。

デフォルトでは、すべての物理ボディとエリアはレイヤーとマスクが`1`に設定されています。
これはすべて互いに接触することを意味します。

物理レイヤーは数字で表現されますが、名前をつけることで何が何なのかの経過を追うことができます。

### レイヤー名の設定

物理レイヤーに名前をつけましょう。
プロジェクト設定に移動します。

メニューでレイヤー名、3Dレンダリングに移動すると、レイヤーに入力フィールドがあります。
そこで`player, enemies, world`の3つのレイヤーを名付けます。

これで物理ノードにそれらを割り当てることができます。

### レイヤーとマスクの割り当て


メインシーンで`Ground`ノードを選択します。
インスペクタで`Collision`セクションを見ると、ノードのレイヤーとマスクがグリッドとして表示されています。

Groundは3つ目のレイヤーである`world`がふさわしいです。
では、レイヤーを`3`に、マスクを`off`にします。

マスクプロパティはノードが他の物理オブジェクトとの相互作用を行うものなので、Groundノードには必要ありません。
Groundはただクリーチャーたちが落ちないようにするためだけにあります。

次に設定するのがプレイヤーとモブです。
まずは`player.tscn`を開きましょう。

プレイヤーノードも先ほどと同じようにCollisionセクションを開きます。
では、レイヤーを`1`に、マスクを`2,3`にします。

モブノードも`Collision`セクションを開きます。
では、レイヤーを`2`に、マスクを`off`にします。
この設定はモンスターが互いにすり抜けることを意味します。
また、モブは`XZ`方向にしか動かないので`world`レイヤーをマスクする必要がありません。

## ジャンプ

ジャンプに必要なコードは2行のみです。
`player.gd`を開き、`_physics_process()`内にジャンプの強さを制御するコードを記述します。

`fall_acceleration`を定義した後に`jump_impulse`を追加します。

```godotengine
#...
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 20


func _physics_process(delta):
	#...

	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse

	#...
```

`is_on_floor()`メソッドは`CharacterBody3D`クラスのツールです。
これはフレーム中にボディが床と衝突した場合`true`を返します。

キャラクターが床にいてプレイヤーがジャンプすれば、即座に垂直方向の速度を付与します。
ゲームでは操作がすぐに反応することがとても重要で、またこのような瞬間的な加速は不自然でも気持ちがいいものです。

### モブを踏みつける

次に押し潰しの仕組みを追加してみましょう。
キャラクターをモンスターの上で跳ねさせながら、同時にモンスターを倒せるようにします。

モンスターとの衝突を検出し、それを床との衝突と区別する必要があります。
そのために`group`タグ機能を使用します。

モブシーンを開き、Mobノードを選択します。
右側のグループドックで一覧を表示し、`mob`という名前の新しいグループを作成をします。

これでコード上からグループを使用して床との衝突とモンスターとの衝突を区別できるようになりました。

### 押し潰しの仕組みをコーディング

`player.gd`にて押し潰しと跳ね返りをコーディングします。

まずは`bounce_impulse`という新しいプロパティを作成します。
これは敵を潰した時に、キャラクターを跳ね返す時に使用する変数です。

```godotengine
# Vertical impulse applied to the character upon bouncing over a mob in
# meters per second.
@export var bounce_impulse = 16
```

次に`_physics_process()`のジャンプのコードの下に以下のループを追加します。
Godotエンジンは`move_and_slide()`を使う時、滑らかに動かすためにボディを複数回連続で動かす時があります。
そのために起きたすべての衝突をループしなければなりません。

ループの各反復で、モブに着地したかどうかチェックし、着地した場合モブを倒して跳ね返します。

```godotengine
func _physics_process(delta):
	#...

	# Iterate through all collisions that occurred this frame
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)

		# If there are duplicate collisions with a mob in a single frame
		# the mob will be deleted after the first collision, and a second call to
		# get_collider will return null, leading to a null pointer when calling
		# collision.get_collider().is_in_group("mob").
		# This block of code prevents processing duplicate collisions.
		if collision.get_collider() == null:
			continue

		# If the collider is with a mob
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# we check that we are hitting it from above.
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# If so, we squash it and bounce.
				mob.squash()
				target_velocity.y = bounce_impulse
				# Prevent further duplicate calls.
				break
```

上記のコードについて説明します。

`get_slide_collision_count(), get_slide_collision()`はどちらもCharacterBody3Dクラスのものです。

`get_slide_collision()`はKinematicCollision3Dオブジェクトを返し、衝突がどこでどのように起きたかの情報を持ちます。

モンスターに着地したかどうかはベクトル内積を使用します。
衝突の方戦は衝突が起きた平面に対して垂直な3Dベクトルです。
内積によってベクトルを上方向と比べることができます。

内積が0より大きい場合、2つのベクトルは90度未満の角度です。
値が0.1以上ならモンスターのほぼ上にいることがわかります。

押し潰しと跳ね返りを処理するロジックの後、`mob.squash()`が重複して呼ばれないように`break`文でループを早めに終了させます。
そうしなければ一度のキルでスコアを重複してカウントしてしまうようなバグが起きるからです。

まだ`mob.squash()`を定義していないので、モブクラスに追加します。

`mob.gd`を開き、`signal squashed`シグナルを定義します。
そして`squash()`というシグナルを発信しモブを破棄する関数を追加します。

```godotengine
# Emitted when the player jumped on the mob.
signal squashed

# ...


func squash():
	squashed.emit()
	queue_free()
```

次のレッスンではスコアにポイントを加算するためにこのシグナルを使います。

これでモンスターにジャンプしてキルできるようになったはずです。
テストして確認してみましょう！
