# プロジェクトの設定

> 参考：https://docs.godotengine.org/ja/4.x/getting_started/first_2d_game/01.project_setup.html

まず初めに、プロジェクトのセットアップを行います。

新規プロジェクトを作成する際に、[dodge_the_creeps_2d_assets.zip](https://github.com/godotengine/godot-docs-project-starters/releases/download/latest-4.x/dodge_the_creeps_2d_assets.zip)をダウンロードしておきます。
ダウンロードしたら、解凍して`fonts, art`ディレクトリをプロジェクトに移動させます。

このゲームはポートレートモード（縦向き）にデザインされるので、
ゲームウィンドウのサイズを調整する必要があります。
プロジェクト設定のディスプレイ、ウィンドウタブを開き、幅高さを`480x720`に設定します。

また、「ストレッチ」オプションでモードを`canvas_items`に、アスペクトを`keep`にします。
これで異なるサイズのスクリーンでも、同じようにゲームが拡大縮小されて表示されます。

## プロジェクトの編成

このプロジェクトでは、3つの独立したシーン（`Player, Mob, HUD`）を作成し、ゲームの`Main`シーンに配置します。

より大規模なプロジェクトでは、シーンとスクリプトをフォルダ分けすると便利です。
小さなゲームでは`res://`と呼ばれるプロジェクトのルートフォルダにファイルをまとめた方が良いです。

プロジェクトを配置できたら、Playerシーンを作成する次のレッスンに進みましょう。
