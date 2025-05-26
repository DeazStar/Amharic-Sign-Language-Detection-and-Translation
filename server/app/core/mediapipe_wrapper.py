import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import cv2 as cv
import numpy as np
import time
import os

class MediaPipeWrapper:
    def __init__(self):
        """
        Initializes the MediaPipe wrapper for detecting up to two hands.
        """
        self.base_option = python.BaseOptions(model_asset_path='./hand_landmarker.task')
        self.option = vision.HandLandmarkerOptions(
            base_options=self.base_option,
            num_hands=2,
            running_mode=vision.RunningMode.IMAGE
        )
        self.detector = vision.HandLandmarker.create_from_options(self.option)
        self.num_hands = 2

    def process_from_image(self, img: np.array):
        # Convert the BGR image to RGB before processing.
        rgb_frame = cv.cvtColor(img, cv.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

        results = self.detector.detect(mp_image)

        return results


    def get_landmarks_from_hands(self, detected_hands) -> np.ndarray:
        """
        Extracts and returns a flattened array of hand landmarks.
        If fewer than num_hands are detected, pads with zero landmarks.

        :param detected_hands: list of NormalizedLandmarkList from MediaPipe result.hand_landmarks
        :return: np.ndarray of shape (21 * num_hands, 3)
        """
        point_array = []

        if detected_hands is not None:
            for hand_landmarks in detected_hands:  # hand_landmarks is already a list of points
                for point in hand_landmarks:       # directly iterate points here
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

        :param detection_result: HandLandmarkerResult object
        :return: np.ndarray of shape (num_hands,) or None if no hands detected
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


    def show_landmarks(self, img_path, results=None):
        """
        Draws landmarks and handedness on an image using MediaPipe Tasks API.
        Saves annotated image to 'data/annotated/<timestamp>.png'.
        """
        os.makedirs("data/annotated", exist_ok=True)
        image = cv.flip(cv.imread(img_path), 1)

        if results is None:
            results = self.process_from_image(image)

        print(results)

        annotated_image = image.copy()

        if not results.hand_landmarks:
            print("No hands detected.")
            return

        image_height, image_width, _ = image.shape

        for i, hand_landmarks in enumerate(results.hand_landmarks):
            print(f'Hand {i + 1} landmarks:')
            index_tip = hand_landmarks[8]  # Index finger tip
            print(f'Index tip: ({index_tip.x * image_width:.1f}, {index_tip.y * image_height:.1f})')

            # Draw landmarks and connections
            for landmark in hand_landmarks:
                cx, cy = int(landmark.x * image_width), int(landmark.y * image_height)
                cv.circle(annotated_image, (cx, cy), 3, (0, 255, 0), -1)

            # Draw connections manually (21 predefined landmark indices)
            connections = mp.solutions.hands.HAND_CONNECTIONS
            for connection in connections:
                start_idx, end_idx = connection
                start = hand_landmarks[start_idx]
                end = hand_landmarks[end_idx]
                x1, y1 = int(start.x * image_width), int(start.y * image_height)
                x2, y2 = int(end.x * image_width), int(end.y * image_height)
                cv.line(annotated_image, (x1, y1), (x2, y2), (0, 0, 255), 1)

        output_path = f'data/annotated/{int(time.time())}.png'
        cv.imwrite(output_path, cv.flip(annotated_image, 1))
        print(f"Saved annotated image to: {output_path}")

    def hands_spacial_position(self, landmarks: np.ndarray) -> np.ndarray:
        """
        Encodes the hands position in the picture.
        Can be used to calculate the trajectory.
        Warning: the coordinates of the given landmarks should not be centered on the hand itself.
            Thus, "world_landmarks" are not acceptable.
        :param landmarks: array of landmarks, like the result of get_landmarks_from_hands.
        NOT world landmarks, as those are centered on the hand!
        TODO: do we want to strictly differentiate between world and other landmarks?
        TODO: make a warning if dynamic gesture appears stationary
        :return: the encoding
        """
        reshaped = landmarks.reshape((-1, 21, 3))
        return np.mean(reshaped, axis=1)

    def get_landmarks_at_position(landmarks: np.ndarray, index: int) -> np.ndarray:
        """
        Returns the landmarks at the given position from a flat array of landmarks.
        Assumes 21 3d landmarks per hand.
        :param landmarks: flat array of landmarks, like the result of pipeline.get_landmarks_from_image
        :param index: the index of the hand
        :return: the landmarks for the given index
        """
        return landmarks[index * 21 * 3: (index + 1) * 21 * 3]