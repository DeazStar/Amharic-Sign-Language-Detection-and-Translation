import cv2
import matplotlib.pyplot as plt

class HandVisualizer:
    def __init__(self):
        pass
    
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
