# ffmpeg_builder_for_win

[Shift Media Project](https://shiftmediaproject.github.io/)の素晴らしいツール群を使用して、ffmpegをVisual Studio Build Toolsを使ってビルドするPowerShellスクリプトです。

ビルドに関しては[FFmpeg/readme\.txt](https://github.com/ShiftMediaProject/FFmpeg/blob/master/SMP/readme.txt)の手順を参考に、YASMを追加インストールするステップを追加しています。

## 実行にあたっての前提条件

* Visual Studio Build Tools がインストールされていること
* Git For Windowsがインストールされ、コマンドラインで使用できること
* PowerShellの最新バージョンがインストールされていること
## 使い方

1. このレポジトリをクローンします
2. x64 Native Tool Command Promptを起動し、クロ－ンしたディレクトリに移動します。
3. pwshを起動します。
4. build.ps1を実行します。<br>
-Cleanを指定すると作業ディレクトリをすべて削除したのち、ビルドします。<br>
-BuiltTypebuild/rebuild/cleanのオプションが選択できます（規定値：build）。<br>
-ObjTypeでDebug/Release/DebugDLL/ReleaseDLL/ReleaseDLLStaticDepsのオプションが選択できます。（規定値：Release）<br>
-CpuTypeでx86/x64が選択できます。（規定値：x64）
5. msvc\binにオブジェクトが生成されます。

## 注意事項

* 途中2回、NASM/YASMのインストールで管理者モードへの切り替え確認ダイアログが出ますので、すべて「はい」としてください。
