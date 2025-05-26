from typing import Dict, List
import numpy as np

def pad_trajectories(trajectories: dict, target_timesteps=6) -> dict:
    for hand in trajectories:
        current_len = trajectories[hand].shape[0]
        if current_len < target_timesteps - 1:
            pad_width = ((0, target_timesteps - 1 - current_len), (0, 0))
            trajectories[hand] = np.pad(trajectories[hand], pad_width=pad_width, mode='constant')
        else:
            trajectories[hand] = trajectories[hand][:target_timesteps - 1]
    return trajectories

def combine_landmarks_and_trajectory(landmarks: np.ndarray, trajectories: dict) -> np.ndarray:
    left_traj = trajectories['left']
    right_traj = trajectories['right']
    combined = []
    for i in range(landmarks.shape[0]):
        lm = landmarks[i].flatten()
        if i < left_traj.shape[0]:
            traj = np.concatenate([left_traj[i], right_traj[i]])
        else:
            traj = np.zeros(6)
        combined.append(np.concatenate([lm, traj]))
    return np.array(combined)


def load_one_sample_with_keyframes_from_frames(
    frames: List[np.ndarray],
    wrapper,
    cleaner,
    builder,
    num_keyframes: int = 6
) -> Dict[str, object]:
    """
    Processes a single sample (list of frames), extracts sorted world landmarks,
    computes trajectory, applies keyframe filtering, and returns a dictionary
    with 'landmark' and 'trajectory'.

    Parameters:
        frames (List[np.ndarray]): List of frames (as images).
        wrapper: MediaPipe wrapper instance.
        cleaner: SequenceCleaner instance for keyframe extraction.
        builder: GeneralDirectionBuilder for trajectory computation.
        num_keyframes (int): Number of keyframes per sequence.

    Returns:
        dict: Contains 'landmark' and 'trajectory'.
    """
    frame_hand_landmarks = []     # Raw hand_landmarks (trajectory input)
    frame_world_landmarks = []    # Sorted world landmarks (model input)
    frame_handedness = []         # Handedness for sorting and trajectory

    for image in frames:
        if image is None:
            continue

        mp_result = wrapper.process_from_image(image)

        if not mp_result.hand_landmarks or not mp_result.hand_world_landmarks:
            continue

        raw_landmark = wrapper.get_landmarks_from_hands(mp_result.hand_landmarks)
        frame_hand_landmarks.append(raw_landmark.reshape(wrapper.num_hands, 21, 3))
        handedness = wrapper.get_handedness(mp_result)
        frame_handedness.append(handedness)

        raw_world = wrapper.get_landmarks_from_hands(mp_result.hand_world_landmarks)
        sorted_world = np.zeros((wrapper.num_hands, 21, 3), dtype=np.float32)
        for i, hand in enumerate(handedness):
            if hand == 0:  # left
                sorted_world[0] = raw_world[i * 21:(i + 1) * 21]
            elif hand == 1:  # right
                sorted_world[1] = raw_world[i * 21:(i + 1) * 21]
        frame_world_landmarks.append(sorted_world)

    if len(frame_hand_landmarks) < num_keyframes:
        raise ValueError("Not enough valid frames to extract keyframes.")

    key_frames = cleaner.extract_key_frames_dual_hand(
        frame_hand_landmarks, frame_handedness, num_keyframes
    )

    filtered_world_landmarks = [frame_world_landmarks[i] for i in key_frames]
    filtered_landmarks = [frame_hand_landmarks[i] for i in key_frames]
    filtered_handedness = [frame_handedness[i] for i in key_frames]

    trajectory = builder.make_trajectory(filtered_landmarks, filtered_handedness)

    return {
        "landmark": np.array(filtered_world_landmarks),   # (K, 2, 21, 3)
        "trajectory": trajectory                           # {'left': (K-1, 3), 'right': (K-1, 3)}
    }
    

def pad_single_sample(x, target_timesteps=6):
    current_len = x.shape[0]
    if current_len < target_timesteps:
        pad_width = ((0, target_timesteps - current_len), (0, 0))  # Pad time axis only
        x_padded = np.pad(x, pad_width=pad_width, mode='constant')
    else:
        x_padded = x[:target_timesteps]  # Optional: truncate if longer
    return x_padded