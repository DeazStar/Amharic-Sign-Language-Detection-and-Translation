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

# # === USAGE ===
# wrapper = MediaPipeWrapper()
# # 
# # # Load your image
# frame = cv2.imread('./cropped_hand.jpg')  # 👈
# print(frame.shape)
# landmark = wrapper.detect_hands(frame)
# print(landmark)
# # Resize image before processing (important!)
# #frame = cv2.resize(frame, (640, 480))
# #
# #cv2.imshow('Original Image', frame)
# #cv2.waitKey(0)
# #cv2.destroyAllWindows()
# #'''
# 
# cropped_hand = wrapper.extract_hand_roi(frame)
# 
# # Define your desired window width and height
# desired_width = 800
# desired_height = 600
# 
# if cropped_hand is not None:
#     save_path = 'cropped_hand.jpg'  # 👈 where you want to save
#     cv2.imwrite(save_path, cropped_hand)
# else:
#     print("No hand detected.")
# 
# cv2.waitKey(0)
# cv2.destroyAllWindows()