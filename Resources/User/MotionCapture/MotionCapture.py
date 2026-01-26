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
    print("pose callback!!!!!")

class CPoseLandmarker:
    def __init__(self):
        self._Loaded = False

    def IsLoaded(self):
        return self._Loaded
    
    def Load(self):
        # ポーズランドマーカーの設定
        options = PoseLandmarkerOptions(
            base_options=BaseOptions(model_asset_path=model_path), # 学習モデルの指定
            running_mode=VisionRunningMode.IMAGE
        )

        # オプションをもとにポーズランドマーカーを作成
        print("PoseLandmarker created.")
        self._landmarker = PoseLandmarker.create_from_options(options)
        self._Loaded = True

    def detect(self, mp_image):
        result = self._landmarker.detect(mp_image)
        pose_landmarks = result.pose_landmarks[0]

        if pose_landmarks != None:
            print(len(pose_landmarks))

#
def main():
    print("Motion capture Started.")

    # Poseタスク作成
    poseTask = CPoseLandmarker()
    poseTask.Load()

    # opencvで0番目のWebカメラを起動
    cap = cv2.VideoCapture(0)

    while cap.isOpened():
        # Webカメラの映像を取得
        ret, frame = cap.read()

        if ret == True:
            # 終了キーを検知したら抜ける
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

            # フレームを画面に表示
            cv2.imshow('WebCam Frame', frame)

            # Webカメラ映像のデータを作成
            img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=img_rgb)

            # Pose検出
            if(poseTask.IsLoaded()):
                poseTask.detect(mp_image)
        else:
            break

    # キャプチャをリリース
    cap.release()

    # ウィンドウを閉じる
    cv2.destroyAllWindows()

    print("Motion capture finished.")

#        
main()