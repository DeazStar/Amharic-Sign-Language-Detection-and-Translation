import cv2
from typing import List
import numpy as np

def load_frames_from_video(video_path: str, max_frames: int = None) -> List[np.ndarray]:
    frames = []
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"Error opening video file: {video_path}")
        return frames

    frame_idx = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frames.append(frame)
        frame_idx += 1

        if max_frames and frame_idx >= max_frames:
            break

    cap.release()
    print(f"Loaded {frame_idx} frames from video: {video_path}")
    return frames
