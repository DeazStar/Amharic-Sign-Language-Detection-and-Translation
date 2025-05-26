from enum import Enum
from src.utils.mediapipe_wrapper import MediaPipeWrapper
import numpy as np

DIMENSIONS = 3  # x, y, and z (always 3 for consistency)


class Direction(Enum):
    UP = 1
    RIGHT = UP
    INTO = UP
    STATIONARY = 0
    DOWN = -1
    LEFT = DOWN
    AWAY = DOWN


class GeneralDirectionBuilder:
    """
    Composes a trajectory as a sequence of Direction enum(1/0/-1) on multiple axi.
    Inspired by https://ieeexplore-ieee-org.tudelft.idm.oclc.org/stamp/stamp.jsp?tp=&arnumber=485888
    """
    def __init__(self, zero_precision = 0.1, use_scaled_zero_precision = True):
        """

        Args:
            zero_precision: how much is considered "no movement on the axis"
            use_scaled_zero_precision: if True, the zero precision is scaled by the
        maximal displacement over an axis, but remains at least equal to self.zero_precision.
        This mitigates the problem of the zero precision being too small for fast movements.
        """
        self.zero_precision = zero_precision
        self.use_scaled_zero_precision = use_scaled_zero_precision
        self.mp = MediaPipeWrapper()

    def make_trajectory(
        self,
        landmark_sequence,
        handedness_sequence
      ):
        """
        Creates trajectories for each hand based on handedness across frames.

        Args:
            landmark_sequence: sequence of np.ndarrays with shape (num_hands, 21, 3)
            handedness_sequence: list of np.ndarrays with shape (num_hands,), values in {0, 1, -1}
        Returns:
            dict with keys 'left' and 'right' containing np.ndarrays of trajectory
        """
        num_frames = len(landmark_sequence)

        trajectories = {
            "left": [],
            "right": []
        }

        last_positions = {
            "left": None,
            "right": None
        }

        for i in range(num_frames):
            frame_landmarks = landmark_sequence[i]
            frame_handedness = handedness_sequence[i]

            positions = self.mp.hands_spacial_position(frame_landmarks)

            for h_index, hand_label in enumerate(frame_handedness):
                hand_name = "left" if hand_label == 0 else "right"
                current_position = positions[h_index]

                if last_positions[hand_name] is not None:
                    direction = self.make_step_directions(
                        last_positions[hand_name],
                        current_position,
                        self.zero_precision,
                        self.use_scaled_zero_precision
                    )
                    trajectories[hand_name].append(direction)

                last_positions[hand_name] = current_position

        # Convert to np.array
        for key in trajectories:
            trajectories[key] = np.array(trajectories[key])

        return trajectories


    @staticmethod
    def make_step_directions(previous, current,
                             zero_precision, use_scaled_zero_precision):
        """
        Creates the directions for a single step
        Args:
            previous: the previous position
            current: the current position
            zero_precision: how much is considered "no movement on the axis"
            use_scaled_zero_precision: if True, the zero precision is scaled.
        Returns:
            the directions for the step
        """
        if previous.shape != (DIMENSIONS,) or current.shape != (DIMENSIONS,):
            raise ValueError(f"Expected 3D vectors, got {previous.shape} and {current.shape}")

        directions = []
        if use_scaled_zero_precision:
            # increase zero precision if the hand moved a lot
            max_displacement = np.max(np.abs(current - previous))
            if max_displacement > zero_precision * 2:
                zero_precision = max_displacement / 2

        for i in range(DIMENSIONS):
            lower_boundary = previous[i] - zero_precision
            upper_boundary = previous[i] + zero_precision
            if lower_boundary > current[i]:
                directions.append(Direction.DOWN.value)
            elif upper_boundary < current[i]:
                directions.append(Direction.UP.value)
            else:
                directions.append(Direction.STATIONARY.value)
        return np.array(directions)

    @staticmethod
    def filter_repeated(trajectory):
        """
        Removes consecutively repeated directions.
        Args:
            trajectory
        """
        filtered = []
        last = None
        for direction in trajectory:
            if not np.array_equal(direction, last):
                filtered.append(direction)
            last = direction
        return np.array(filtered)

    @staticmethod
    def filter_stationary(trajectory):
        """
        Removes completely stationary directions.
        Args:
            trajectory
        Returns:

        """
        filtered = []
        zeros = np.zeros(DIMENSIONS)
        for direction in trajectory:
            if not np.array_equal(direction, zeros):
                filtered.append(direction)
        return np.array(filtered)

    @staticmethod
    def from_flat(flat) :
        """
        Converts a flat trajectory to a 2d numpy array removing NaNs.
        Args:
            flat: flat trajectory
        Returns:
            2d numpy array
        """
        reshaped = flat.reshape(-1, DIMENSIONS)
        # shorten if found NaNs (they appear when converting to pandas)
        for i in range(len(reshaped)):
            if np.isnan(reshaped[i]).all():
                return reshaped[:i]
        return reshaped

    def pad_trajectories(traj_dict):
        left = traj_dict['left']
        right = traj_dict['right']

        # Fix: convert any 1D empty array to (0, 3)
        if left.ndim == 1:
            left = left.reshape(0, 3)
        if right.ndim == 1:
            right = right.reshape(0, 3)

        len_left = len(left)
        len_right = len(right)

        if len_left < len_right:
            pad = np.zeros((len_right - len_left, 3), dtype=np.float32)
            left = np.concatenate([left, pad], axis=0)
        elif len_right < len_left:
            pad = np.zeros((len_left - len_right, 3), dtype=np.float32)
            right = np.concatenate([right, pad], axis=0)

        return {'left': left, 'right': right}
