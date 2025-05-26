import numpy as np
from augmentation import ImageLevelAugmentation

class Stage:
    """
    Class to represent a single stage of the pipeline.
    """

    def __init__(self, mp, initial_index, brightness, rotation):
        """
        Args:
            mp: mediapipe object to be used for processing
            initial_index: the index of the stage in the pipeline before any order optimizations happened
            brightness: the brightness that will be added to each image
            rotation: the rotation that will be applied to each image
        """
        self.mp = mp
        self.initial_index = initial_index
        self.brightness = brightness
        self.rotation = rotation
        self.recognized_counter = 0
        self.last_detected_hands = None
        self.last_detected_handedness = None
        self.imglevelaug = ImageLevelAugmentation()

    def process(self, image):
        """
        Process the image. Apply brightness and rotation.
        Args:
            image: the image to process
        Returns:
            processed image
        """
        image = self.imglevelaug.increase_brightness(image, self.brightness)
        image = self.imglevelaug.rotate(image, self.rotation)

        return image

    def get_landmarks(self, image: np.ndarray):
        """
        Gets the mediapipe landmarks from an image. Saves them to self.last_detected_hands because
        the method is called asynchronously (so can't really return anything).
        Args:
            image: the image to process
        """
        converted_image = self.process(image)
        res = self.mp.process_from_image(converted_image)

        self.last_detected_hands = res.hand_landmarks
        self.last_detected_handedness = res.handedness

    def get_world_landmarks(self, image: np.ndarray):
        """
        Gets the mediapipe world landmarks from an image. Saves them to self.last_detected_hands because
        the method is called asynchronously (so can't really return anything).
        Args:
            image: the image to process
        """
        converted_image = self.process(image)
        res = self.mp.process_from_image(converted_image)

        self.last_detected_hands = res.world_landmarks
        self.last_detected_handedness = res.handedness
