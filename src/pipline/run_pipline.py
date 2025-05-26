import csv
import os
from src.config.settings import STATIC_SIGN_PATH_TRAIN, DYNAMIC_SIGN_PATH_TRAIN, \
    STATIC_CSV_OUTPUT_TRAIN, DYNAMIC_CSV_OUTPUT_TRAIN, STATIC_LABEL_PATH_TRAIN, \
    DYNAMIC_LABEL_PATH_TRAIN, STATIC_SIGN_PATH_TEST, DYNAMIC_SIGN_PATH_TEST, \
    STATIC_CSV_OUTPUT_TEST, DYNAMIC_CSV_OUTPUT_TEST, STATIC_LABEL_PATH_TEST, \
    DYNAMIC_LABEL_PATH_TEST
from src.preprocessor.image_preprocessor import ImagePreProcessor
from src.preprocessor.augmentation import HandLandmarkAugmenter
from src.preprocessor.normalization import Normalization
from src.utils.mediapipe_wrapper import MediaPipeWrapper
from src.preprocessor.sequence_cleaner import SequenceCleaner
from src.preprocessor.trajectory_builder import GeneralDirectionBuilder
from src.utils.path_utiils import file_exists
from pprint import pprint
import os
import cv2
from natsort import natsorted
import numpy as np

def process_and_save_static(train=True):
    image_processor = ImagePreProcessor(num_classes=33)

    if train:
        sign_path = STATIC_SIGN_PATH_TRAIN
        label_path = STATIC_LABEL_PATH_TRAIN
        output_path = STATIC_CSV_OUTPUT_TRAIN
    else:
        sign_path = STATIC_SIGN_PATH_TEST
        label_path = STATIC_LABEL_PATH_TEST
        output_path = STATIC_CSV_OUTPUT_TEST

    if not file_exists(sign_path):
        raise FileNotFoundError(f"Sign path {sign_path} does not exist.")

    if not file_exists(label_path):
        raise FileNotFoundError(f"Label path {label_path} does not exist.")

    X, y = image_processor.load_multiple_images(sign_path, label_path)

    augmenter = HandLandmarkAugmenter()
    normalizer = Normalization()

    result = {}

    one_hot_encoding, label = y

    for i, sample in enumerate(X):
        lbl = label[i]

        # Initialize entry if not already present
        if lbl not in result:
            result[lbl] = {
                "landmark": [],
                "encoding": None
            }

        # Augment and normalize each augmented sample
        augmented_samples = augmenter.augment(sample)
        normalized_augmented = [normalizer.normalize_hand_landmarks(aug) for aug in augmented_samples]

        # Normalize the original sample
        normalized_original = normalizer.normalize_hand_landmarks(sample)

        # Add to result
        result[lbl]["landmark"].extend(normalized_augmented)
        result[lbl]["landmark"].append(normalized_original)

        # Set encoding (only once per label)
        if result[lbl]["encoding"] is None:
            result[lbl]["encoding"] = one_hot_encoding[i]

    # Save to CSV

    with open(output_path, 'w', newline='') as csvfile:
        fieldnames = ['label', 'landmark', 'encoding']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for label, data in result.items():
            for landmark in data["landmark"]:
                writer.writerow({
                    'label': label,
                    'landmark': landmark.tolist(),  # Convert numpy array to list
                    'encoding': data["encoding"].numpy().tolist()  # Convert tensor to list
                })


def process_and_save_dynamic(num_keyframes=6):
    '''
    Loads all samples from the root_dir, extracts sorted world landmarks (for model),
       computes trajectory (from original landmarks), applies keyframe filtering,
       and returns a list of dictionaries with 'landmark', 'trajectory', and 'label'.

       Parameters:
           num_keyframes (int): Number of keyframes per sequence.

       Returns:
           None
    '''
    # due the time it takes to convert to frames and saving it we will just store it as a numpy array
    # not as a csv file
    root_dir = DYNAMIC_LABEL_PATH_TRAIN

    mp_wrapper = MediaPipeWrapper()
    cleaner = SequenceCleaner()
    builder = GeneralDirectionBuilder()

    all_data = []

    for folder_name in os.listdir(root_dir):
        folder_path = os.path.join(root_dir, folder_name)
        if not os.path.isdir(folder_path):
            continue

        label = folder_name.split("_")[0]

        image_files = [
            f for f in os.listdir(folder_path)
            if f.lower().endswith((".jpg", ".jpeg", ".png"))
        ]
        image_files = natsorted(image_files)

        frame_hand_landmarks = []     # Raw hand_landmarks (trajectory input)
        frame_world_landmarks = []    # Sorted world landmarks (model input)
        frame_handedness = []         # Handedness for sorting and trajectory

        for filename in image_files:
            img_path = os.path.join(folder_path, filename)
            image = cv2.imread(img_path)
            if image is None:
                print(f"Failed to load: {img_path}")
                continue

            mp_result = mp_wrapper.process_from_image(image)

            if not mp_result.hand_landmarks or not mp_result.hand_world_landmarks:
                continue

            # Store raw hand_landmarks and handedness
            raw_landmark = mp_wrapper.get_landmarks_from_hands(mp_result.hand_landmarks)
            frame_hand_landmarks.append(raw_landmark.reshape(mp_wrapper.num_hands, 21, 3))
            handedness = mp_wrapper.get_handedness(mp_result)
            frame_handedness.append(handedness)

            # Extract and sort world landmarks
            raw_world = mp_wrapper.get_landmarks_from_hands(mp_result.hand_world_landmarks)
            sorted_world = np.zeros((mp_wrapper.num_hands, 21, 3), dtype=np.float32)
            for i, hand in enumerate(handedness):
                if hand == 0:  # left
                    sorted_world[0] = raw_world[i * 21:(i + 1) * 21]
                elif hand == 1:  # right
                    sorted_world[1] = raw_world[i * 21:(i + 1) * 21]
            frame_world_landmarks.append(sorted_world)

        # Skip if not enough frames
        if len(frame_hand_landmarks) < num_keyframes:
            continue

        # === Extract keyframes ===
        key_frames = cleaner.extract_key_frames_dual_hand(
            frame_hand_landmarks, frame_handedness, num_keyframes
        )

        # === Filtered for each data type ===
        filtered_world_landmarks = [frame_world_landmarks[i] for i in key_frames]
        filtered_landmarks = [frame_hand_landmarks[i] for i in key_frames]
        filtered_handedness = [frame_handedness[i] for i in key_frames]

        # === Build trajectory ===
        trajectory = builder.make_trajectory(filtered_landmarks, filtered_handedness)

        # === Store result ===
        all_data.append({
            "landmark": np.array(filtered_world_landmarks),   # (K, 2, 21, 3)
            "trajectory": trajectory,                          # {'left': (K-1, 3), 'right': (K-1, 3)}
            "label": label
        })

    # Save the data
    np.save(DYNAMIC_CSV_OUTPUT_TEST, all_data)

if __name__ == "__main__":
    process_and_save_static(train=True)
    process_and_save_static(train=False)
    process_and_save_dynamic()
