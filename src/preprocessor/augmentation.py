import random
import numpy as np

class HandLandmarkAugmenter:
    def __init__(
        self,
        scale_range=(0.8, 1.2),
        shear_range=(-0.1, 0.1),
        translate_range=(-0.05, 0.05),
        rotation_range=(-10, 10),
        jitter_std=0.03,
        scale_prob=0.8,
        shear_prob=0.6,
        translate_prob=0.6,
        rotation_prob=0.7,
        jitter_prob=0.9,
        
    ):
        """
        Initialize the hand landmark augmenter with transformation parameters.

            Args:
                scale_range: Tuple (min, max) for scaling factors in x and y.
                shear_range: Tuple (min, max) for shear factors in x and y.
                translate_range: Tuple (min, max)
                TODO: finis the docstring
        """
        self.scale_range = scale_range
        self.shear_range = shear_range
        self.translate_range = translate_range
        self.rotation_range = rotation_range
        self.jitter_std = jitter_std
        self.scale_prob = scale_prob
        self.shear_prob = shear_prob
        self.translate_prob = translate_prob
        self.rotation_prob = rotation_prob
        self.jitter_prob = jitter_prob
        
    def _non_uniform_scaling(self, landmark):
        """
        Perform non-uniform scaling on the landmark.
        
            Args:
                landmark: The hand landmark to be scaled.
        """
        if random.random() < self.scale_prob:
            sx = random.uniform(*self.scale_range)
            sy = random.uniform(*self.scale_range)
            scale_matrix = np.array([sx, sy])
            landmark = landmark * scale_matrix
        return landmark
    
    def _shear_transform(self, landmarks):
        """
        Perform shear transformation on the landmark.
        
            Args:
                landmarks: The hand landmark to be sheared.
        """
        if random.random() < self.shear_prob:
            sxy = random.uniform(*self.shear_range)
            shear_matrix = np.array([[1, sxy], [0, 1]])
            landmarks = landmarks @ shear_matrix
        return landmarks
    
    def _micro_rotation(self, landmarks):
        """
        Perform micro rotation on the landmark.
        
            Args:
                landmarks: The hand landmark to be rotated.
        """
        if random.random() < self.rotation_prob:
            angle_deg = random.uniform(*self.rotation_range)
            angle_rad = np.deg2rad(angle_deg)
            cos_a, sin_a = np.cos(angle_rad), np.sin(angle_rad)
            rotation_matrix = np.array([[cos_a, -sin_a], [sin_a, cos_a]])
            landmarks = landmarks @ rotation_matrix
        return landmarks
    
    def _jitter_landmarks(self, landmarks):
        """
        Add Gaussian noise to the landmarks.
        
            Args:
                landmarks: The hand landmark to be jittered.
        """
        if random.random() < self.jitter_prob:
            noise = np.random.normal(0, self.jitter_std, landmarks.shape)
            landmarks = landmarks + noise
        return landmarks

    def augment(self, landmarks):
        """
        Apply each augmentation independently to the same original landmarks.

        Args:
            landmarks: The original hand landmarks (NumPy array of shape Nx2)

        Returns:
            A list of augmented landmarks, one for each augmentation type.
        """
        augmented_landmarks = []
        augment_fns = [
            self._non_uniform_scaling,
            self._shear_transform,
            self._micro_rotation,
            self._jitter_landmarks,
        ]
        for fn in augment_fns:
            # Copy the landmarks so each function works on the original
            original_copy = np.copy(landmarks)
            augmented = fn(original_copy)
            augmented_landmarks.append(augmented)

        return augmented_landmarks

