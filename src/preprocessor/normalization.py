import numpy as np
import cv2
from src.utils.mediapipe_wrapper import MediaPipeWrapper

class Normalization:
    def __init__(self):
        """
        mcp_indices: Indcies of hte MCP joints
            5: Represent the Index finger
            9: Represent the Middle finger
            13: Represent the Ring finger
            17: Represent the Pinky finger
        """
        self.mcp_indices = [5, 9, 13, 17]

    def bbox_normalize_landmarks(self, landmarks, roi, image_width, image_height):
        """
        Normalizes landmarks relative to the bounding box (roi).

        Args:
            landmarks: List of landmarks with normalized coordinates (x, y) relative to full image.
            roi: Tuple (roi_x_min, roi_y_min, roi_x_max, roi_y_max) in pixel coordinates.

        Returns:
            landmarks_normalized: Landmarks normalized to [0,1] within the ROI box.
        """
        roi_x_min, roi_y_min, roi_x_max, roi_y_max = roi

        width = roi_x_max - roi_x_min
        height = roi_y_max - roi_y_min

        landmarks_px = np.array([[lm.x, lm.y] for lm in landmarks])

        landmarks_px[:, 0] = (landmarks_px[:, 0] * image_width - roi_x_min) / width
        landmarks_px[:, 1] = (landmarks_px[:, 1] * image_height - roi_y_min) / height

        return landmarks_px

    def center_hand_landmark(self, landmarks):
        """
        Centers the hand landmarks around the palm center.
        
        Args:
            landmarks: The hand landmarks (numpy array).
        """
        mcp_joints = landmarks[self.mcp_indices]
        center = np.mean(mcp_joints, axis=0)
        centered = landmarks - center
        return centered
    
    def scale_hand_landmark(self, landmarks):
        """
        Scales the hand landmarks based on the distance from the MCP joints to the center.
        
        Args:
            landmarks: The hand landmarks (numpy array).
        """
        mcp_joints = landmarks[self.mcp_indices]
        center = np.mean(mcp_joints, axis=0)
        dists = np.linalg.norm(mcp_joints - center, axis=1)
        scale = np.mean(dists)
        if scale < 1e-6:
            scale = 1e-6
        return landmarks / scale
    
    def rotate_hand_landmark(self, landmarks):
        """
        Rotates the hand landmarks to align the index finger (MCP joint) upward.
        
        Args:
            landmarks: The hand landmarks (numpy array).
        """
        # Align L9 (index MCP) upward
        vec = landmarks[9]
        reference = np.array([0, -1])
        dot = np.dot(vec, reference)
        det = vec[0] * reference[1] - vec[1] * reference[0]
        theta = np.arctan2(det, dot)
    
        cos_t = np.cos(-theta)
        sin_t = np.sin(-theta)
        R = np.array([
            [cos_t, -sin_t],
            [sin_t,  cos_t]
        ])
    
        return landmarks @ R.T
    
    def normalize_hand_landmarks(self, landmarks):
        """
        Normalizes the hand landmarks by centering, scaling, and rotating.
        
        Args:
            landmarks: The hand landmarks (numpy array).
        """
        centered_landmarks = self.center_hand_landmark(landmarks)
        scaled_landmarks = self.scale_hand_landmark(centered_landmarks)
        rotated_landmarks = self.rotate_hand_landmark(scaled_landmarks)
        
        # New: normalize to [-1, 1] range
        max_val = np.max(np.abs(rotated_landmarks))
        if max_val > 0:
            rotated_landmarks = rotated_landmarks / max_val

        return rotated_landmarks
