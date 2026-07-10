# ヘッドアップディスプレイ

> 参考：https://docs.godotengine.org/ja/4.x/getting_started/first_2d_game/06.heads_up_display.html

このゲームに必要な最後の要素は、スコアやゲームオーバーメッセージ、リスタートボタンなどのUIです。

新しいシーンを作成し、HUDという名前のCanvasLayerノードを追加します。

HUDはゲームビューの上にオーバーレイとして表示される"heads_up_display"の略です。

CanvasLayerノードを使用すると、ゲームの他の部分よりも上のレイヤーにUI要素を描画できるため、
表示される情報がプレイヤーやモブなどによって隠れることがなくなります。

HUDには以下の実装を行います。

- ScoreTimerによって更新されるスコア
- ゲームオーバー、リスタートなどのメッセージ
- スタートボタン

UI要素の基本ノードはControlです。
UIを作成するには、Label, Button, Controlノードを使用します。

HUDの子要素は次のとおりです。

- Label: ScoreLabel
- Label: Message
- Button: StartButton
- Timer: MessageTimer

ScoreLabelを選択し、テキストフィールドに数字を入力します。
Godotのデフォルトフォントではうまくいかないので、ゲームアセットのXolonium-Regular.ttfを使用します。

フォントを追加したらFont Sizesを`64`に設定します。
Message, StartButtonにも同様に設定します。

次にノードを配置します。
手動でも可能ですが、アンカーのプリセットを使用すれば正確に配置することができます。

### ScoreLabel

1. `0`というテキストを追加。
2. Horizontal Alignment, Vertical Alignmentを`Center`に設定。
3. アンカーのプリセットで`中央上`を選択。

### Message

1. `Dodge the Creeps!`というテキストを追加。
2. Horizontal Alignment, Vertical Alignmentを`Center`に設定。
3. Autowrap Modeを`Word`に設定。
4. Control - Layout/Transform -> Size Xを`480`に設定。
5. アンカーのプリセットで`中央`を選択。

### StartButton

1. `Start`というテキストを追加。
2. Control - Layout/TransformでSizeXを`200`、SizeYを`100`に設定。
3. アンカーのプリセットで`中央下`を選択。
4. Control - Layout/TransformでPositionYを`580`に設定。

MessageTimerでWaitTimeを`2`に設定し、OneShotプロパティを`On`に設定します。

`HUD`にスクリプトをアタッチします

```godotengine
extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game
```

Get Readyのようなメッセージを表示したいので、以下のコードを追加します。

```godotengine
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
```

プレイヤーが負けた時の処理も必要です。
以下のコードでは、2秒間GameOverを表示し、タイトル画面に戻り、少し間をおいてStartボタンが表示されます。

```godotengine
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
```

`create_timer()`は何か表示する前に少し時間を置きたい場合など、遅延させるのに便利な関数です。

以下のコードをHUDに追加してスコアを更新します。

```godotengine
func update_score(score):
	$ScoreLabel.text = str(score)
```

StartButtonの`pressed()`シグナルとMessageTimerの`timeout()`シグナルをHUDノードに接続して、
新しい関数に書きのコードを追加します。

```godotengine
func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()
```

## HUDをメインに接続する

HUDシーン作成が完了したらMainに戻ります。
Playerシーンと同じようにHUDシーンをMainにインスタンス化して配置します。
ツリー全体は以下のようになります。

- Main
    - Player
    - MobTimer
    - ScoreTimer
    - StartTimer
    - StartPosition
    - MobPath
        - MobSpawnLocation
    - HUD

次にHUD機能をMainスクリプトに接続します。
これにはMainシーンに幾つかの変更が必要です。

シグナルタブでHUDの`start_game`シグナルをMainノードの`new_game()`関数に接続します。
これにはConnect α SignalのPickボタンで`new_game`メソッドを選択するか、
Receiver Methodの下に`new_game`と入力します。
スクリプト内で`new_game()`の横に、緑色の接続アイコンが表示されていれば成功です。

`new_game()`で、スコア表示を更新し、メッセージを表示します。
`game_over()`では、対応するHUD関数を呼び出す必要があります。
最後にこれを`_on_score_timer_timeout()`に追加して、変更されたスコアと同期して表示を維持します。

```godotengine
$HUD.update_score(score)
$HUD.show_message("Get Ready")

$HUD.show_game_over()

$HUD.update_score(score)
```

これでプレイする準備が整いました。試しにプロジェクトを起動してみましょう。

## 古いクリープを削除する

ゲームオーバーまでプレイしてから新しいゲームを開始すると、敵が画面に表示されたままです。
これは新しいゲームを始める時に消しておいた方が良いでしょう。
それには、全てのモブたちに自身の削除を指示する方法が必要です。
これはグループ機能を使えば可能です。

モブシーンからシグナルタブの横にあるグループタグを選択し、`mobs`という名前の新しいグループを作成をします。

次にメインの`new_game()`関数に以下のコードを追加します。

```godotengine
get_tree().call_group("mobs", "quere_free")
```

`call_group()`関数はグループ内のすべてのノードに対して名前付きの関数を呼び出します。
ここではすべてのモブに自分自身を削除するように指示しています。

今の時点でゲームはほぼ完成しています。
次のパートでは、背景、音楽、キーボードショートカットを追加して、もう少し磨きをかけます。
