from fastapi import APIRouter, UploadFile, File
import os
import shutil
from app.core.preprocess import load_frames_from_video
from app.core.mediapipe_wrapper import MediaPipeWrapper
from app.core.trajectory import GeneralDirectionBuilder
from app.core.predict import SignLanguageModel
from app.services.sequence_cleaner import SequenceCleaner
from app.utils.helpers import load_one_sample_with_keyframes_from_frames, pad_trajectories, combine_landmarks_and_trajectory , pad_single_sample

router = APIRouter()

@router.post("/translate")
async def translate_video(file: UploadFile = File(...)):
    # Save uploaded file
    try:
        file_location = f"temp_videos/{file.filename}"
        os.makedirs("temp_videos", exist_ok=True)
        with open(file_location, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Load frames
        frames = load_frames_from_video(file_location)
        if not frames:
            return {"error": "Could not process video frames."}

        # Initialize processors
        wrapper = MediaPipeWrapper()
        cleaner = SequenceCleaner()
        builder = GeneralDirectionBuilder()

        # Process frames
        single_data = load_one_sample_with_keyframes_from_frames(frames, wrapper, cleaner, builder)
        single_data['trajectory'] = pad_trajectories(single_data['trajectory'])
        to_test = combine_landmarks_and_trajectory(single_data['landmark'], single_data['trajectory'])
        to_test = pad_single_sample(to_test)
        # Predict
        model = SignLanguageModel()
        predicted_label = model.predict(to_test)

        # Clean up
        os.remove(file_location)

        return {"prediction": predicted_label}
    except Exception as e:
        return {"errorssssss": str(e)}