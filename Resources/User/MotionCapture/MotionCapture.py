# https://ai.google.dev/edge/mediapipe/solutions/setup_python?hl=ja
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import numpy as np
import cv2
from socket import *
import struct
import sys

# トレーニング済みのモデル
model_path = "pose_landmarker_heavy.task"

# クラスの省略形を宣言
BaseOptions = mp.tasks.BaseOptions
PoseLandmarker = mp.tasks.vision.PoseLandmarker
PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
PoseLandmarkerResult = mp.tasks.vision.PoseLandmarkerResult
VisionRunningMode = mp.tasks.vision.RunningMode

class CUDPSocket:
    def __init__(self):
        pass

    def Connect(self, address, port):
        # 送信元
        self._SrcAddr = (address, port)

        # 接続
        self.udpClient = socket(AF_INET, SOCK_DGRAM)
        self.udpClient.connect((address, port))

    def Send(self, data):
        self.udpClient.send(data)

    def Close(self):
        self.udpClient.close()

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

    def detect(self, _debugShow, frame, mp_image, data):
        result = self._landmarker.detect(mp_image)
        if(result == None):
            return

        if result.pose_landmarks == None or len(result.pose_landmarks) == 0:
            return
        
        pose_landmarks = result.pose_landmarks[0]
        if pose_landmarks == None:
            return
        
        # ランドマークからポーズの角度を計算
        self.calcPose(pose_landmarks, data)
        
        # デバッグ描画
        if(_debugShow):
            h, w, _= frame.shape

            for landmark in pose_landmarks:
                x = int(w * landmark.x)
                y = int(h * landmark.y)

                cv2.circle(frame, (x, y), 5, (255, 0, 0), -1)

    def calcPose(self, pose_landmarks, data):
        # 顔の向き
        ParamAngleX = 1.0
        data.extend(struct.pack('<f', ParamAngleX))
        
        ParamAngleY = 0.0
        data.extend(struct.pack('<f', ParamAngleY))
        
        ParamAngleZ = 0.0
        data.extend(struct.pack('<f', ParamAngleZ))
        
        # 体の向き
        ParamBodyAngleX = 0.0
        data.extend(struct.pack('<f', ParamBodyAngleX))
        
        ParamBodyAngleY = 0.0
        data.extend(struct.pack('<f', ParamBodyAngleY))
        
        ParamBodyAngleZ = 0.0
        data.extend(struct.pack('<f', ParamBodyAngleZ))
        
        # 腕
        ParamArmL = 0.0
        data.extend(struct.pack('<f', ParamArmL))
        
        ParamArmR = 0.0
        data.extend(struct.pack('<f', ParamArmR))
        
        # 手
        ParamHandL = 0.0
        data.extend(struct.pack('<f', ParamHandL))
        
        ParamHandR = 0.0
        data.extend(struct.pack('<f', ParamHandR))
        
#
def main():
    print("Motion capture Started.")

    _debugShow = True
    
    # UDP接続
    udp = CUDPSocket()
    udp.Connect('127.0.0.1', 5000)

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
            
            # Webカメラ映像のデータを作成
            img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=img_rgb)

            #
            data = bytearray()

            head = "LG2D"
            data.extend(head.encode('utf-8'))

            version = 1
            data.extend(struct.pack('<i', version))

            # Pose検出
            if(poseTask.IsLoaded()):
                poseTask.detect(_debugShow, frame, mp_image, data)

            # フレームを画面に表示
            if(_debugShow):
                cv2.imshow('WebCam Frame', frame)

            # データ送信
            udp.Send(data)

        else:
            break

    # キャプチャをリリース
    cap.release()

    # ウィンドウを閉じる
    cv2.destroyAllWindows()

    # UDPを閉じる
    udp.Close()

    print("Motion capture finished.")

#        
main()