from fastapi import APIRouter, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import numpy as np
import cv2
from app.services.mediapipe_service import MediaPipeWrapper
from app.services.model_service import predict_hand_sign
from app.services.normalization import Normalization
from app.utils.audio_generator import generate_base64_audio
from app.utils.amharic_map import AMHARIC_MAP

router = APIRouter()
mp_wrapper = MediaPipeWrapper()
normalizer = Normalization()

@router.post("/process-image/")
async def process_image(file: UploadFile = File(...)):
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="Invalid image file")

    contents = await file.read()
    np_array = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(np_array, cv2.IMREAD_COLOR)

    if img is None:
        raise HTTPException(status_code=400, detail="Could not read image")

    hand_roi, hand_landmarks, roi = mp_wrapper.extract_hand_roi(img)
    
    
    if hand_landmarks is not None:
        landmarks_array = mp_wrapper.landmarks_to_array(hand_landmarks)
        normalized_original = normalizer.normalize_hand_landmarks(landmarks_array)
        # normalized_original = normalized_original.reshape(1, 21, 2)
        prediction = predict_hand_sign(normalized_original)

    else:
        raise HTTPException(status_code=422, detail="No hand detected")
    
    print(prediction)
    prediction = AMHARIC_MAP.get(prediction, "Unknown")
    
    # audio_base64 = generate_base64_audio(prediction)
    return {
    "prediction": prediction

}