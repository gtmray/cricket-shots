import pandas as pd
import numpy as np
import os
import mediapipe as mp
import pickle
import re
import sys
import cv2
import matplotlib.pyplot as plt

from warnings import filterwarnings
filterwarnings('ignore')

path_list = []
data_path = 'ShotsData'
classes_list = sorted(os.listdir(data_path))
for cls in classes_list:
    path_list.append(f"{data_path}/{cls}")


pkl_filename = str(sys.argv[1])
with open(pkl_filename, 'rb') as file:
    model = pickle.load(file)

df = pd.read_csv('shots_data.csv')
cor = df.corr()
threshold = 0.2
target_corr = abs(cor["target"])
features_list = list(target_corr[target_corr>threshold].index)
features_list.remove('target')

body_part = df.columns
idx_features = [i for i in range(len(body_part)) if body_part[i] in features_list]

def predict_shot(path):

    mpPose = mp.solutions.pose
    pose = mpPose.Pose()
    mpDraw = mp.solutions.drawing_utils # For drawing keypoints
    points = mpPose.PoseLandmark # Landmarks

    data = []
    img = cv2.imread(path)
    imageWidth, imageHeight = img.shape[:2]
    imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    results = pose.process(imgRGB)

    # Run this only when landmarks are detected
    if results.pose_landmarks:
        mpDraw.draw_landmarks(imgRGB, results.pose_landmarks, mpPose.POSE_CONNECTIONS,
                                mpDraw.DrawingSpec(color=(245,117,66), thickness=2, circle_radius=2),
                                mpDraw.DrawingSpec(color=(245,66,230), thickness=2, circle_radius=2))
        landmarks = results.pose_landmarks.landmark
        for i,j in zip(points,landmarks):
            data = data + [j.x, j.y, j.z, j.visibility]
    data = [data[i] for i in idx_features]
    result = int(model.predict([data])[0])
    plt.figure(figsize=(10, 10))
    # Remove the text class number
    text = f"Prediction:{re.sub('[^a-zA-Z]', ' ', classes_list[result])}"
    plt.text(0, -5, text, size='xx-large', weight=500)
    plt.imshow(imgRGB)
    plt.grid(False)
    plt.axis(False)
    plt.show()

    # plt.savefig("leg glance aasif", bbox_inches='tight') 

path = str(sys.argv[2])
predict_shot(path)