import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import cv2
import numpy as np

class MediaPipeWrapper:
    def __init__(self):
        """
        Initializes the MediaPipe wrapper for hand detection.
        """
        self.base_option = python.BaseOptions(model_asset_path='./hand_landmarker.task')
        self.option = vision.HandLandmarkerOptions(base_options=self.base_option,
                                                   num_hands=2)
        self.detector = vision.HandLandmarker.create_from_options(self.option)
        self.num_hands = 2

    def detect_hands(self, frame):
        """
        Detects hands in the image using MediaPipe HandLandmarker (Tasks API).

        Args:
            frame: Input image (numpy array, BGR).
        """
        H, W, _ = frame.shape
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
        result = self.detector.detect(mp_image)
        return result

    def extract_hand_roi(self, frame):
        """
        Extracts the cropped hand region and landmarks from the input frame.

        Args:
            frame: Input image (numpy array, BGR).
        Returns:
            hand_roi: Cropped hand image (numpy array) or None if no hand detected.
            hand_landmarks: List of landmarks or None if no hand detected.
        """
        result = self.detect_hands(frame)

        H, W, _ = frame.shape

        if not result.hand_landmarks:
            return None, None  # No hands detected

        # Assume first detected hand
        hand_landmarks = result.hand_landmarks[0]

        x_coords = [lm.x for lm in hand_landmarks]
        y_coords = [lm.y for lm in hand_landmarks]

        x_min = int(min(x_coords) * W)
        y_min = int(min(y_coords) * H)
        x_max = int(max(x_coords) * W)
        y_max = int(max(y_coords) * H)

        margin_x = int(0.3 * (x_max - x_min))
        margin_y = int(0.3 * (y_max - y_min))

        roi_x_min = max(0, x_min - margin_x)
        roi_y_min = max(0, y_min - margin_y)
        roi_x_max = min(W, x_max + margin_x)
        roi_y_max = min(H, y_max + margin_y)

        hand_roi = frame[roi_y_min:roi_y_max, roi_x_min:roi_x_max]

        roi = (roi_x_min, roi_y_min, roi_x_max, roi_y_max)

        return hand_roi, hand_landmarks, roi

    def process_from_image(self, img):
        # Convert the BGR image to RGB before processing.
        rgb_frame = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

        results = self.detector.detect(mp_image)

        return results

    def get_landmarks_from_hands(self, detected_hands):
        """
        Extracts and returns a flattened array of hand landmarks.
        If fewer than num_hands are detected, pads with zero landmarks.

        Args:
            detected_hands: list of NormalizedLandmarkList from MediaPipe result.hand_landmarks
        Returns:
            np.ndarray of shape (21 * num_hands, 3)
        """
        point_array = []

        if detected_hands is not None:
            for hand_landmarks in detected_hands:
                for point in hand_landmarks:
                    point_array.append([point.x, point.y, point.z])

        # Pad with zeros if fewer than self.num_hands hands are detected
        required_points = 21 * self.num_hands
        current_points = len(point_array)
        if current_points < required_points:
            point_array.extend([[0.0, 0.0, 0.0]] * (required_points - current_points))

        return np.array(point_array)

    def get_handedness(self, detection_result):
        """
        Returns handedness array for each detected hand.
        - 0 for Left
        - 1 for Right
        - If 1 hand detected, assign opposite label to the missing hand.
        - If no hands detected, return None to indicate skipping.

        Args:
            detection_result: HandLandmarkerResult object
        Returns:
            np.ndarray of shape (num_hands,) or None if no hands detected
        """
        handedness = np.full(self.num_hands, -1)

        detected_hands = []
        if detection_result.handedness:
            for i, hand in enumerate(detection_result.handedness):
                if i >= self.num_hands:
                    break
                label = hand[0].category_name
                hand_val = 0 if label == 'Left' else 1
                handedness[i] = hand_val
                detected_hands.append(hand_val)

        if len(detected_hands) == 0:
            # No hands detected, skip this frame
            return None

        if self.num_hands == 2 and len(detected_hands) == 1:
            # Assign opposite label to the missing hand
            for i in range(self.num_hands):
                if handedness[i] == -1:
                    handedness[i] = 1 - detected_hands[0]

        return handedness
    def hands_spacial_position(self, landmarks):
        """
        Encodes the hands position in the picture.
        Can be used to calculate the trajectory.
        Warning: the coordinates of the given landmarks should not be centered on the hand itself.
            Thus, "world_landmarks" are not acceptable.
        Args:
            landmarks: array of landmarks, like the result of get_landmarks_from_hands.
        NOT world landmarks, as those are centered on the hand!
        TODO: do we want to strictly differentiate between world and other landmarks?
        TODO: make a warning if dynamic gesture appears stationary
        Returns:
            the encoding
        """
        reshaped = landmarks.reshape((-1, 21, 3))
        return np.mean(reshaped, axis=1)

    def get_landmarks_at_position(landmarks, index):
        """
        Returns the landmarks at the given position from a flat array of landmarks.
        Assumes 21 3d landmarks per hand.
        Args:
            landmarks: flat array of landmarks, like the result of pipeline.get_landmarks_from_image
            index: the index of the hand

        Returns:
            the landmarks for the given index
        """
        return landmarks[index * 21 * 3: (index + 1) * 21 * 3]
