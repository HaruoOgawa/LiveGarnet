# LiveGarnet
[![IMAGE ALT TEXT HERE](https://github.com/user-attachments/assets/cd121296-8e0d-48b4-9d7b-1981aa59175b)](https://www.youtube.com/watch?v=OW3TKoJMNUw)
## 導入手順
1. 以下のコマンドを実行
```
mkdir LiveGarnetApp
cd LiveGarnetApp
git clone https://github.com/HaruoOgawa/Garnet.git
cd Garnet
git checkout 0.3.0
cd ../
git clone https://github.com/HaruoOgawa/LiveGarnet.git

```
2. https://aps.autodesk.com/developer/overview/fbx-sdk からWindows VS2022用のFBX SDKのインストーラーを取得しインストール
3. [Garnet/Src/Library/FBXSDK](https://github.com/HaruoOgawa/Garnet/tree/0.3.0/Garnet/Src/Library/FBXSDK) に2020.3.7フォルダの中身をコピー
<img width="600" height="357" alt="image" src="https://github.com/user-attachments/assets/78e3806d-5295-44c4-9f59-a0d8325dce3a" />

4. LiveGarnet\LiveGarnet.slnをVisual Studio 2022で開き、ソリューション構成をDebugGLFWとしてビルドする
5. ビルドしてできたx64/DebugGLFWフォルダにLiveGarnet/Resourcesフォルダをコピー
6. x64\DebugGLFW\LiveGarnet.exeを実行
7. キーボードの「0 ~ 1」を押して表情やモーションを変更します
