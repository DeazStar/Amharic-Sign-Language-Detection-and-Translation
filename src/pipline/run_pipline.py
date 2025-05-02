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
from src.utils.path_utiils import file_exists
from pprint import pprint

def process_and_save(option="static", train=True):
    image_processor = ImagePreProcessor(num_classes=33)
    
    if option not in ["static", "dynamic"]:
        raise ValueError("option must be either 'static' or 'dynamic'")
    
    if train:
        sign_path = STATIC_SIGN_PATH_TRAIN if option=="static" else DYNAMIC_SIGN_PATH_TRAIN
        label_path = STATIC_LABEL_PATH_TRAIN if option=="static" else DYNAMIC_LABEL_PATH_TRAIN
        output_path = STATIC_CSV_OUTPUT_TRAIN if option=="static" else DYNAMIC_CSV_OUTPUT_TRAIN
    else:
        sign_path = STATIC_SIGN_PATH_TEST if option=="static" else DYNAMIC_SIGN_PATH_TEST
        label_path = STATIC_LABEL_PATH_TEST if option=="static" else DYNAMIC_LABEL_PATH_TEST
        output_path = STATIC_CSV_OUTPUT_TEST if option=="static" else DYNAMIC_CSV_OUTPUT_TEST

    if not file_exists(sign_path):
        raise FileNotFoundError(f"Sign path {sign_path} does not exist.")
    
    if not file_exists(label_path):
        raise FileNotFoundError(f"Label path {label_path} does not exist.")
    
    #TODO: handle remote downlaod file 
    
    #TODO: handle video data
    if option == "dynamic":
        raise NotImplementedError("Dynamic sign processing is not implemented yet.")
    
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

if __name__ == "__main__":
    process_and_save("static", train=True)
    process_and_save("static", train=False)
    # process_and_save("dynamic")
    
    