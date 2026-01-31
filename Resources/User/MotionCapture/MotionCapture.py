# https://ai.google.dev/edge/mediapipe/solutions/setup_python?hl=ja
# pip install mediapipe opencv-python numpy numpy-quaternion
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import numpy as np
import quaternion
import cv2
from socket import *
import struct
import sys
import math
import time

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

        self._max_frame = 2
        self._current_frame = 0

        self._sum_of_landmark = [
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
        ]

        self._current_landmark = [
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
            np.array([ 0.0, 0.0, 0.0 ]),
        ]

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
            return False

        if result.pose_landmarks == None or len(result.pose_landmarks) == 0:
            return False
        
        pose_landmarks = result.pose_landmarks[0]
        if pose_landmarks == None:
            return False
        
        #
        if len(pose_landmarks) != 33:
            return False
        
        # デバッグ描画
        if(_debugShow):
            h, w, _= frame.shape
            index = 0

            right_eye_index      = 2
            left_eye_index       = 5
            mouth_right_index    = 9
            mouth_left_index     = 10

            for landmark in self._current_landmark:
                x = int(w * landmark[0])
                y = int(h * landmark[1])

                color = (255, 0, 0)

                if index == right_eye_index or index == left_eye_index:
                    color = (0, 0, 255)
                elif index == mouth_right_index or index == mouth_left_index:
                    color = (255, 255, 255)

                cv2.circle(frame, (x, y), 5, color, -1)

                index += 1
        
        # ランドマークからポーズの角度を計算
        if(not self.calcPose(pose_landmarks, data)):
            return False
        
        return True

    def calcPose(self, pose_landmarks, data):
        #
        if(not self.correctLandmarks(pose_landmarks)):
            return False

        #
        nose_index           = 0
        right_eye_index      = 2
        left_eye_index       = 5
        mouth_right_index    = 9
        mouth_left_index     = 10
        right_shoulder_index = 11
        left_shoulder_index  = 12

        #
        nose_pos = self.getPos(nose_index)
        right_eye_pos = self.getPos(right_eye_index)
        left_eye_pos = self.getPos(left_eye_index)
        mouth_right_pos = self.getPos(mouth_right_index)
        mouth_left_pos = self.getPos(mouth_left_index)
        right_shoulder_pos = self.getPos(right_shoulder_index)
        left_shoulder_pos = self.getPos(left_shoulder_index)

        #
        HeadQuat = self.calcHeadRotate(right_eye_pos, left_eye_pos, mouth_right_pos, mouth_left_pos)
        BodyQuat = self.calcBodyRotate(nose_pos, right_shoulder_pos, left_shoulder_pos)
        LArmQuat = quaternion.quaternion(1.0, 0.0, 0.0, 0.0)
        RArmQuat = quaternion.quaternion(1.0, 0.0, 0.0, 0.0)
        LHandQuat = quaternion.quaternion(1.0, 0.0, 0.0, 0.0)
        RHandQuat = quaternion.quaternion(1.0, 0.0, 0.0, 0.0)

        # 顔の回転(クォータニオン)
        data.extend(struct.pack('<f', HeadQuat.x))
        data.extend(struct.pack('<f', HeadQuat.y))
        data.extend(struct.pack('<f', HeadQuat.z))
        data.extend(struct.pack('<f', HeadQuat.w))
        
        # 体の向き
        data.extend(struct.pack('<f', BodyQuat.x))
        data.extend(struct.pack('<f', BodyQuat.y))
        data.extend(struct.pack('<f', BodyQuat.z))
        data.extend(struct.pack('<f', BodyQuat.w))
        
        # 左腕
        data.extend(struct.pack('<f', LArmQuat.x))
        data.extend(struct.pack('<f', LArmQuat.y))
        data.extend(struct.pack('<f', LArmQuat.z))
        data.extend(struct.pack('<f', LArmQuat.w))
        
        # 右腕
        data.extend(struct.pack('<f', RArmQuat.x))
        data.extend(struct.pack('<f', RArmQuat.y))
        data.extend(struct.pack('<f', RArmQuat.z))
        data.extend(struct.pack('<f', RArmQuat.w))
        
        # 左手
        data.extend(struct.pack('<f', LHandQuat.x))
        data.extend(struct.pack('<f', LHandQuat.y))
        data.extend(struct.pack('<f', LHandQuat.z))
        data.extend(struct.pack('<f', LHandQuat.w))
        
        # 右手
        data.extend(struct.pack('<f', RHandQuat.x))
        data.extend(struct.pack('<f', RHandQuat.y))
        data.extend(struct.pack('<f', RHandQuat.z))
        data.extend(struct.pack('<f', RHandQuat.w))

        return True

    def correctLandmarks(self, pose_landmarks):
        # 位置の平均を取る
        for i in range(0, len(pose_landmarks)):
            landmark = pose_landmarks[i]
            pos = np.array([ landmark.x, landmark.y, landmark.z ])

            self._sum_of_landmark[i] += pos
        
        self._current_frame += 1

        # 規定フレーム数を越したら現在の位置を更新する
        if(self._current_frame >= self._max_frame):
            self._current_frame = 0

            for i in range(0, len(self._sum_of_landmark)):
                pos = self._sum_of_landmark[i] / self._max_frame

                # Zは捨てる
                # pos[2] = 0.0

                self._current_landmark[i] = pos
                self._sum_of_landmark[i] = np.array([ 0.0, 0.0, 0.0 ])

            # 平均位置が更新されたので次に進む
            return True

        return False


    def calcHeadRotate(self, right_eye_pos, left_eye_pos, mouth_right_pos, mouth_left_pos):
        eye_center = (left_eye_pos + right_eye_pos) * 0.5
        mouth_center = (mouth_left_pos + mouth_right_pos) * 0.5

        YVector = (eye_center - mouth_center)
        YVector = YVector / np.linalg.norm(YVector)

        XVector = (right_eye_pos - left_eye_pos)
        XVector = XVector / np.linalg.norm(XVector)

        ZVector = np.cross(XVector, YVector)

        RotMat = np.column_stack([XVector, YVector, ZVector])
        Quat = quaternion.from_rotation_matrix(RotMat)

        return Quat
    
    def calcBodyRotate(self, nose_pos, right_shoulder_pos, left_shoulder_pos):
        shoulder_center = (right_shoulder_pos + left_shoulder_pos) * 0.5

        YVector = nose_pos - shoulder_center
        YVector = YVector / np.linalg.norm(YVector)

        XVector = (right_shoulder_pos - left_shoulder_pos)
        XVector = XVector / np.linalg.norm(XVector)

        ZVector = np.cross(XVector, YVector)

        RotMat = np.column_stack([XVector, YVector, ZVector])
        Quat = quaternion.from_rotation_matrix(RotMat)

        return Quat
    
    def getPos(self, index):
        landmark = self._current_landmark[index]
        pos = np.array([ landmark[0], landmark[1], landmark[2] ])

        # MediaPipeはXY成分は左上が(0, 0)で0~1の値をとる
        # Z成分は-1から1??
        # なのでXY成分は補正が必要
        pos[0] = pos[0] * 2.0 - 1.0
        
        pos[1] = 1.0 - pos[1]
        pos[1] = pos[1] * 2.0 - 1.0

        pos[2] *= -1.0

        return pos
        
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

    # 最初のデータ送信かの判定
    # 最初のデータなら受信側で初期化を行ったりする
    firstMsg = True

    #
    frameIndex = 0

    while cap.isOpened():
        # 60FPSで実行
        # time.sleep(1.0 / 60.0)

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

            # 最初のデータ
            flag = 1 if(firstMsg) else 0
            data.extend(struct.pack('<i', flag))
            firstMsg = False

            # タイムコード 
            data.extend(struct.pack('<i', frameIndex))

            # Pose検出
            poseResult = False
            if(poseTask.IsLoaded()):
                poseResult = poseTask.detect(_debugShow, frame, mp_image, data)

            # フレームを画面に表示
            if(_debugShow):
                cv2.imshow('WebCam Frame', frame)

            # データ送信
            if(poseResult):
                udp.Send(data)
                frameIndex += 1

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