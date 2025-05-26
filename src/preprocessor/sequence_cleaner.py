from src.utils.mediapipe_wrapper import MediaPipeWrapper
import numpy as np

class SequenceCleaner:
  def __init__(self, target_len=6):
    self.target_len = target_len
    self.mp = MediaPipeWrapper()

  def remove_outliers(self, landmark_sequence):
    """
    Method: if dist i-1 to i+1 is less than dist i-1 to i and dist i to i+1, then i is outlier.
    Where dist is the distance between hand positions on the frames.
    Args:
        landmark_sequence: initial landmark sequence
    Returns:
        reduced sequence
    """
    positions = []
    for i in range(len(landmark_sequence)):
        positions.append(self.mp.hands_spacial_position(landmark_sequence[i]))

    non_outliers = [landmark_sequence[0]]
    for i in range(1, len(landmark_sequence) - 1):
        if min(self._distance(positions[i-1], positions[i]), self._distance(positions[i], positions[i+1])) > \
                self._distance(positions[i-1], positions[i+1]):
            # outlier
            continue
        non_outliers.append(landmark_sequence[i])

    non_outliers.append(landmark_sequence[-1])
    return non_outliers

  def extract_key_frames_dual_hand(
      self,
      frame_landmarks,   # Shape: (num_frames, num_hands, 21, 3)
      frame_handedness,  # Shape: (num_frames, num_hands), values: 0 (left), 1 (right), -1 (not detected)
      target_len
  ):
      """
      Extracts key frames based on combined motion of both hands.
      Ensures that left and right hand sequences stay temporally aligned.

      Args:
          frame_landmarks: aggeragate frame landmark of a single sample
          frame_handedness: aggergate frame handedness of a single sample
      """
      full_sequence = []

      for i in range(len(frame_landmarks)):
          landmarks = frame_landmarks[i]
          handedness = frame_handedness[i]

          # Initialize placeholders for left and right hand landmarks
          left_hand = np.zeros((21, 3))
          right_hand = np.zeros((21, 3))

          for h_index, hand_label in enumerate(handedness):
              if hand_label == -1:
                  continue  # Skip if hand not detected
              if hand_label == 0:
                  left_hand = landmarks[h_index]
              elif hand_label == 1:
                  right_hand = landmarks[h_index]

          # Concatenate left and right hand landmarks
          combined = np.concatenate([left_hand, right_hand], axis=0)
          full_sequence.append(combined)

      # Remove outliers based on combined motion
      full_sequence = self.remove_outliers(full_sequence)

      # Compute displacements
      displacements = [0]
      last_pos = self.mp.hands_spacial_position(full_sequence[0])
      for i in range(1, len(full_sequence)):
          pos = self.mp.hands_spacial_position(full_sequence[i])
          displacements.append(self._distance(last_pos, pos))
          last_pos = pos.copy()

      total = sum(displacements)
      interval = total / (target_len - 1)
      running_sum = 0
      key_frames = [0]

      for i in range(1, len(full_sequence)):
          running_sum += displacements[i]
          if running_sum >= interval:
              key_frames.append(i)
              running_sum = 0

      if len(key_frames) < target_len:
          key_frames.append(len(full_sequence) - 1)

      return key_frames


  def _distance(self, pos1, pos2):
      return np.linalg.norm(pos1 - pos2)
