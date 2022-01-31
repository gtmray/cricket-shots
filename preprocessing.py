import mediapipe as mp
import cv2
import numpy as np
import pandas as pd
import os
import sys

path_list = []
data_path = str(sys.argv[1])
classes_list = sorted(os.listdir(data_path))
for cls in classes_list:
    path_list.append(f"{data_path}/{cls}")

def create_features(image_path, target):

    data = [] # List to add columns
    idx = 0 # Index
    mpPose = mp.solutions.pose
    pose = mpPose.Pose()
    mpDraw = mp.solutions.drawing_utils # For drawing keypoints
    points = mpPose.PoseLandmark # Landmarks
  
    for p in points:
        body_part = str(p)[13:] # For extracting name of the body part
        data.append(body_part + "_x") # X co-ordinate
        data.append(body_part + "_y") # Y co-ordinate
        data.append(body_part + "_z") # Z co-ordinate
        data.append(body_part + "_vis") # Visibility
    data.append('target') # Target
    data = pd.DataFrame(columns = data) # DataFrame with only columns (empty)

    for img in os.listdir(image_path):
        temp = []
        img = cv2.imread(image_path + "/" + img)
        imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB) # OpenCV = BGR, Mediapipe = RGB
        results = pose.process(imgRGB) # Pose detection

        if results.pose_landmarks:
            landmarks = results.pose_landmarks.landmark
            for p in landmarks:
                temp = temp + [p.x, p.y, p.z, p.visibility] # Append x, y, z, vis of each part
            temp.append(target)
            data.loc[idx] = temp
            idx += 1
    data.to_csv(f"dataset{target}.csv", index=False) # save the data as a csv file

# Create Features for all classes

for idx, cls in enumerate(path_list):
    create_features(path_list[idx], idx)

df_list = []

# Store the dataframe of each classes in a list
for idx, cls in enumerate(classes_list):
  df_list.append(pd.read_csv(f'dataset{idx}.csv'))

df = pd.concat(df_list)
df.to_csv('shots_data.csv', index=False)

# Remove the df of each classes

for idx, cls in enumerate(classes_list):
  os.remove(f'dataset{idx}.csv')

print("Preprocessing Done!! shots_data.csv file created.")