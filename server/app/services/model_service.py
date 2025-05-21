import os
import numpy as np
from tensorflow.keras.models import load_model

# Load the model once when the service is imported
MODEL_PATH = os.path.join(os.path.dirname(__file__), '../../ml_models/model.keras')
model = load_model(MODEL_PATH)

def predict_hand_sign(landmarks_array: np.ndarray):
    """
    Make a prediction using the hand landmarks array.

    Args:
        landmarks_array (np.ndarray): The flattened landmarks array (e.g., shape (63,))
    Returns:
        prediction (list): The model output as a list (for JSON serialization)
    """
    if landmarks_array is None:
        return {"error": "No landmarks provided"}

    # Add batch dimension: (1, 63)
    input_array = np.expand_dims(landmarks_array, axis=0)

    prediction = model.predict(input_array)


    # return the maximum value index as the predicted class
    maximum_index = 0
    value = -1
    print(prediction)    
    for idx , val in enumerate(prediction[0]):
        if val > value:
            value = val
            maximum_index = idx
    print("maximum index", maximum_index)
    return maximum_index