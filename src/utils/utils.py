import os
import cv2
import imutils

def rename_mov_files(folder_path, number_map):
    """
    Renames .mov files in a specified folder based on a number mapping.
    Files are expected to be in the format: name_number.mov
    Example: natnael_1.mov will be renamed to natnael_4.mov if 1 maps to 4.

    Args:
        folder_path (str): The absolute path to the folder containing the .mov files.
        number_map (dict): A dictionary mapping old numbers to new numbers.
                           Example: {1: 4, 2: 5}
    """
    print(f"Scanning folder: {folder_path}")
    renamed_count = 0
    skipped_count = 0
    error_count = 0

    # Check if the folder path is valid
    if not os.path.isdir(folder_path):
        print(f"Error: Folder not found at '{folder_path}'. Please check the path.")
        return

    for filename in os.listdir(folder_path):
        # Check if the file is a .mov file
        if filename.lower().endswith(".mov"):
            # Split the filename from its extension
            name_part, extension = os.path.splitext(filename)

            # Try to split the name_part by the last underscore
            try:
                # Find the last underscore to correctly separate prefix and number
                last_underscore_index = name_part.rfind('_')
                if last_underscore_index == -1:
                    print(f"Skipping '{filename}': Does not contain an underscore before the number part.")
                    skipped_count += 1
                    continue

                prefix = name_part[:last_underscore_index]
                number_str = name_part[last_underscore_index+1:]

                # Try to convert the number part to an integer
                old_number = int(number_str)

                # Check if this number is in our mapping
                if old_number in number_map:
                    new_number = number_map[old_number]
                    new_filename = f"{prefix}_{new_number}{extension}"

                    old_filepath = os.path.join(folder_path, filename)
                    new_filepath = os.path.join(folder_path, new_filename)

                    # Ensure the new filename doesn't already exist (optional, but good practice)
                    if os.path.exists(new_filepath):
                        print(f"Skipping rename of '{filename}' to '{new_filename}': Target file already exists.")
                        skipped_count +=1
                        continue

                    # Rename the file
                    os.rename(old_filepath, new_filepath)
                    print(f"Renamed: '{filename}' to '{new_filename}'")
                    renamed_count += 1
                else:
                    print(f"Skipping '{filename}': Number '{old_number}' not in mapping.")
                    skipped_count += 1

            except ValueError:
                # This handles cases where the part after underscore is not a number
                print(f"Skipping '{filename}': Could not parse number from filename.")
                skipped_count += 1
            except FileNotFoundError:
                print(f"Error renaming '{filename}': Original file not found (should not happen if listed).")
                error_count +=1
            except Exception as e:
                print(f"An unexpected error occurred with file '{filename}': {e}")
                error_count += 1
        else:
            # Optional: print files that are not .mov if you want to see everything being skipped
            # print(f"Skipping '{filename}': Not a .mov file.")
            pass

    print("\n--- Summary ---")
    print(f"Files renamed: {renamed_count}")
    print(f"Files skipped: {skipped_count}")
    print(f"Errors encountered: {error_count}")

def extract_frames_from_video(video_path, output_dir_base):
    # Get the video filename without extension to create output folder
    video_name = os.path.splitext(os.path.basename(video_path))[0]
    output_dir = os.path.join(output_dir_base, video_name)

    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    # Open the video file
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"Error opening video file: {video_path}")
        return

    frame_idx = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break  # no more frames or error

        # Build the filename for each frame
        frame_filename = os.path.join(output_dir, f"frame_{frame_idx:04d}.jpg")

        # Save the frame as an image
        cv2.imwrite(frame_filename, frame)
        frame_idx += 1

    cap.release()
    print(f"Extracted {frame_idx} frames to folder: {output_dir}")

def extract_frames_from_directory(video_dir, output_dir_base='/content/drive/MyDrive/Capstone project/traning_frames'):
    """
    Iterates through all video files in the specified directory and extracts frames from each.

    :param video_dir: Path to the directory containing video files.
    :param output_dir_base: Base directory where extracted frames will be saved.
    """
    # Supported video file extensions
    video_extensions = ('.mp4', '.mov', '.avi', '.mkv')

    # Iterate through all files in the directory
    for filename in os.listdir(video_dir):
        if filename.lower().endswith(video_extensions):
            video_path = os.path.join(video_dir, filename)
            extract_frames_from_video(video_path, output_dir_base)

def rotate_all_images_in_folder(folder_path, rotation=cv2.ROTATE_90_CLOCKWISE):
    """
    Rotates all .jpg images in the given folder by the specified rotation.
    Overwrites the original images.

    Args:
        folder_path (str): Path to the folder containing frames.
        rotation (int): OpenCV rotation flag. Defaults to 90° clockwise.
                        Options:
                          - cv2.ROTATE_90_CLOCKWISE
                          - cv2.ROTATE_90_COUNTERCLOCKWISE
                          - cv2.ROTATE_180
    """
    for filename in os.listdir(folder_path):
        if filename.lower().endswith(".jpg"):
            filepath = os.path.join(folder_path, filename)
            image = cv2.imread(filepath)
            if image is None:
                print(f"Could not read {filepath}")
                continue

            rotated_image = cv2.rotate(image, rotation)
            cv2.imwrite(filepath, rotated_image)

    print(f"Rotated all .jpg images in: {folder_path}")

def increase_brightness(image, value = 30):
    """
    Update the brightness of the image by a given amount.
    :param image: the image to update
    :param value: by how much to change the brightness
    :return: updated image
    """
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    h, s, v = cv2.split(hsv)

    v = cv2.add(v, value)
    v[v > 255] = 255
    v[v < 0] = 0

    final_hsv = cv2.merge((h, s, v))
    img = cv2.cvtColor(final_hsv, cv2.COLOR_HSV2BGR)
    return img


def rotate(image, degrees = 0):
    """
    Rotate the image by a given angle.
    :param image: the image to rotate
    :param degrees: the amount of degrees by which to rotate the image
    :return: rotated image
    """
    return imutils.rotate_bound(image, degrees)
