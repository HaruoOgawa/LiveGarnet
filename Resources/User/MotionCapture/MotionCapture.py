# https://ai.google.dev/edge/mediapipe/solutions/setup_python?hl=ja
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import numpy as np
import cv2

# トレーニング済みのモデル
model_path = "pose_landmarker_heavy.task"

# クラスの省略形を宣言
BaseOptions = mp.tasks.BaseOptions
PoseLandmarker = mp.tasks.vision.PoseLandmarker
PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
PoseLandmarkerResult = mp.tasks.vision.PoseLandmarkerResult
VisionRunningMode = mp.tasks.vision.RunningMode

# デバッグ出力コールバック
def print_result(result: PoseLandmarkerResult, output_image: mp.Image, timestamp_ms: int):
    print("pose result: {}".format(result))

#
def main():
    # タスク作成
    # ポーズランドマーカーの設定
    options = PoseLandmarkerOptions(
        base_options=BaseOptions(model_asset_path=model_path), # 学習モデルの指定
        running_mode=VisionRunningMode.LIVE_STREAM, # ライブストリーム(Webカメラなどリアルタイム更新映像)モードで起動
        result_callback=print_result
    )

    # オプションをもとにポーズランドマーカーを作成
    with PoseLandmarker.create_from_options(options) as landmarker:
        print("create_from_options")
        
        # opencvで0番目のWebカメラを起動
        cap = cv2.VideoCapture(0)

        while cap.isOpened():
            print("cap.isOpened")

            # Webカメラの映像を取得
            ret, frame = cap.read()

            if ret == True:
                # フレームを画面に表示
                cv2.imshow('WebCam Frame', frame)

                # Webカメラ映像のデータを作成
                img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=img_rgb)

                # シミュレーションを実行
                landmarker.detect(mp_image)

                # 終了キーを検知したら抜ける
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
            else:
                break

        # キャプチャをリリース
        cap.release()

        # ウィンドウを閉じる
        cv2.destroyAllWindows()

        print("finish")

#        
main()