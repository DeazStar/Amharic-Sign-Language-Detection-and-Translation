import numpy as np
from typing import List

class GeneralDirectionBuilder:
    def make_trajectory(self, landmarks: List[np.ndarray], handedness: List[int]) -> dict:
        trajectories = {'left': [], 'right': []}
        for i in range(1, len(landmarks)):
            for hand_idx, hand in enumerate(['left', 'right']):
                prev = landmarks[i - 1][hand_idx][0]
                curr = landmarks[i][hand_idx][0]
                delta = np.subtract(curr, prev)
                trajectories[hand].append(delta)
        for hand in trajectories:
            trajectories[hand] = np.array(trajectories[hand])
        return trajectories
