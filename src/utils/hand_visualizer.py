import cv2
import matplotlib.pyplot as plt
from mediapipe_wrapper import MediaPipeWrapper
import os
import cv2 as cv
import mediapipe as mp
import time

class HandVisualizer:
    def __init__(self):
        self.mp = MediaPipeWrapper()

    def draw_landmarks_on_image(self, image, detection_result):
        """
        Draws hand landmarks on the image.

        Args:
            image: The input image (numpy array).
            detection_result: The result of hand detection containing landmarks.
        """
        # Convert the image to an OpenCV format
        annotated_image = image.copy()

        for hand_landmarks in detection_result.hand_landmarks:
            for landmark in hand_landmarks:
                x, y = int(landmark.x * image.shape[1]), int(landmark.y * image.shape[0])
                cv2.circle(annotated_image, (x, y), 5, (0, 255, 0), -1)

        return annotated_image

    def daraw_hand(self, hand_roi):
        """
        Draws the Region of Interest (ROI) for the hand.

        Args:
            hand_roi: The Region of Interest (ROI) for the hand (numpy array).
        """
        # Convert to RGB for displaying in matplotlib
        hand_roi_rgb = cv2.cvtColor(hand_roi, cv2.COLOR_BGR2RGB)

        # Display the ROI in the notebook
        plt.imshow(hand_roi_rgb)
        plt.axis('off')  # Hide axis
        plt.show()

    def show_landmarks(self, img_path, results=None):
        """
        Draws landmarks and handedness on an image using MediaPipe Tasks API.
        Saves annotated image to 'data/annotated/<timestamp>.png'.
        """
        os.makedirs("data/annotated", exist_ok=True)
        image = cv.flip(cv.imread(img_path), 1)

        if results is None:
            results = self.mp.process_from_image(image)

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

    def hand_trajectory_vizualization(self,trajectory, title):
        axes = ['X', 'Y', 'Z']

        plt.figure(figsize=(12, 6))

        for i in range(3):
            plt.plot(trajectory[:, i], label=f'Direction {axes[i]}')

        plt.yticks([-1, 0, 1], ['DOWN/LEFT/AWAY', 'STATIONARY', 'UP/RIGHT/INTO'])
        plt.xlabel("Step")
        plt.ylabel("Direction")
        plt.title(title)
        plt.legend()
        plt.grid(True)
        plt.show()
