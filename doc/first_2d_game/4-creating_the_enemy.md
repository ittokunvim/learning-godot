# 敵の作成

> 参考：https://docs.godotengine.org/ja/4.x/getting_started/first_2d_game/04.creating_the_enemy.html

次はプレイヤーが避けるべき敵を作ります。
敵の行動はあまり複雑ではありません。
モブは画面の端でランダムで生まれると、ランダムな方向を選び、一直線に進みます。

これから`Mob`シーンを作成し、インスタンス化してゲーム内に任意の数の独立したモブを作成します。

## ノードの設定

では以下のようなシーンを新規作成します。

- RigidBody2D
    - AnimatedSprite2D
    - CollisionShape2D
    - VisibleOnScreenNotifier2D

プレイヤーシーンで行ったように、子ノードを選択できないよう設定します。

モブノードを選択して、インスペクタのRigidBody2Dの`Gravity Scale`プロパティを0にします。
これでモブが下に落ちなくなります。

さらにモブノードのインスペクタでCollisionObject2DのCollisionの`Mask`プロパティの1のチェックを外します。
これでモブ同士が衝突しなくなります。

プレイヤーも同じようにAnimatedSprite2Dを設定します。
今回は`fly, swim, walk`の3つのアニメーションがあります。

`Animation Speed`プロパティの値は3FPSに設定します。

モブにバラエティを持たせるために1つのアニメーションをランダムに選択します。

プレイヤーの画像と同じように、モブの画像も小さくする必要があります。
AnimatedSprite2Dの`Scale`プロパティを`(0.75, 0.75)`に設定します。

プレイヤーシーンと同様に、コリジョンにCapsuleShape2Dを追加します。
図形を画像に合わせるには`Rotation`プロパティを`90`に設定します。

## 敵のスクリプト

モブにスクリプトをアタッチします。

アタッチしたら以下のコードを記述します。
`_ready()`ではアニメーションを再生し3つのアニメーションのいずれかを選択します。

```godotengine
extends RigidBody2D


func _ready():
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()
```

まずアニメーションのリストのAnimatedSprite2Dの`sprite_frame`プロパティから取得します。
値は`["walk", "swim", "fly"]`となります。

GDScriptコードでは、Array.pick_randomメソッドを使用して、これらのアニメーション名をランダムに1つ選択します。

そしてにplay()を呼び出して選択したアニメーションを再生します。

最後にモブが画面外に出た時にモブ自身を削除したいと思います。
VisibleOnScreenNotifier2Dノードの`screen_exited()`シグナルを接続し、以下のコードを追加します。

```godotengine
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
```

`quere_free()`は、基本的にフレームの最後にあるノードを「解放」または削除する関数です。

これでMobシーンが完成です。
プレイヤーと敵ができたので、次のパートではそれらを新しいシーンにまとめます。
ランダムに敵が出現、まっすぐ動くようにし、プロジェクトを遊べるゲームにします。
