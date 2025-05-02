import pandas as pd
import tensorflow as tf
import cv2
from .normalization import Normalization
from src.utils.mediapipe_wrapper import MediaPipeWrapper
import numpy as np
from src.utils.hand_visualizer import HandVisualizer
import os 
import mediapipe as mp
import cv2

class ImagePreProcessor:
    def __init__(self, num_classes):
        """
        Initializes the ImagePreProcessor with  normalziation object
        """

        self.normalization = Normalization()
        self.mediapipewrapper = MediaPipeWrapper()
        self.hand_visualizer = HandVisualizer()
        self.num_classes = num_classes

    def load_labels(self, label_path):
        """
        Load labels from the label file.
        """
        df = pd.read_csv(label_path)
        return dict(zip(df['filename'], df['class']))\

    def one_hot_encoding(self, y):
        """
        Convert labels to one-hot encoding.
        
        Args:
            y: List of labels to be converted.
        """

        sorted_labels = sorted(set(y)) # unique soted labels
        label_to_index = {label: idx for idx, label in enumerate(sorted_labels)}
        indices = [label_to_index[label] for label in y]
        return (tf.one_hot(indices, depth=self.num_classes), y)
    
    def load_single_image(self, file, show=False):
        frame = cv2.imread(file)
        
        H, W, _ = frame.shape
        
        hand_roi, hand_landmarks, roi = self.mediapipewrapper.extract_hand_roi(frame)

        if hand_roi is None:
            raise ValueError(f"Hand not detected in image: {file}")
        
        landmark_px = self.normalization.bbox_normalize_landmarks(hand_landmarks, roi, W, H)
        
        if show:
            annotated_image = self.hand_visualizer.draw_landmarks_on_image(hand_roi, hand_landmarks)
            self.hand_visualizer.draw_hand(annotated_image)
        return landmark_px

    def load_multiple_images(self, image_path, lable_path):
        """
        Load images from a direcotry
        Extract landmarks from each image
        Normalize the landmarks
        Return the normalized landmarks and labels
        
        Args:
            image_path: Path to the image file.
            label_path: Path to the label file.
        """
        
        X = []
        y = []
        labels = self.load_labels(lable_path)
        
        files = sorted([
            f for f in os.listdir(image_path) 
            if f.lower().endswith(('.jpg', '.jpeg', '.png')) and not f.startswith('invert')
        ])
        
        for file in files:
            file_path = os.path.join(image_path, file)
            
            normalized_landmarks = self.load_single_image(file_path)
            
            if normalized_landmarks is not None:
                X.append(normalized_landmarks)
                label =  labels.get(file, -1)
                if label == -1:
                    print(f"Warning: Missing label for {file}")
                y.append(label)
            else:
                print(f"Warning: Skipping {file} due to missing hand landmarks")

        y = self.one_hot_encoding(np.array(y))
        
        return np.array(X), y
