import os
import numpy as np
from tensorflow.keras.models import load_model

labels = ['ሀገር', 'ልጅ', 'መድሃኒት', 'ምክንያት', 'ምግብ',
          'ቀን', 'ባለቤት', 'ባክቴሪያ', 'ቤተሰብ', 'ትክክል',
          'አልፈልግም', 'አሳ', 'ወንበር', 'ውጤት', 'ዜና',
          'ጆሮ', 'ጉንፋን', 'ፆታ', 'ፍራፍሬ' , 'እቅድ']

labels.sort()

MODEL_PATH = os.path.join(os.path.dirname(__file__), '../../ml_models/video_model.keras')

class SignLanguageModel:
    def __init__(self):
        self.model = load_model(MODEL_PATH)

    def predict(self, data: np.ndarray) -> str:
        prediction = self.model.predict(data.reshape(1, 6, 132))
        predicted_index = np.argmax(prediction)
        print("Predicted index:", predicted_index)
        return labels[predicted_index]
