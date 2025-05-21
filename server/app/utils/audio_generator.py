from transformers import VitsModel, AutoTokenizer
import torch
import numpy as np
import scipy.io.wavfile
import io
import base64
import subprocess

# Load model and tokenizer once (outside the function for efficiency)
model = VitsModel.from_pretrained("facebook/mms-tts-amh")
tokenizer = AutoTokenizer.from_pretrained("facebook/mms-tts-amh")

def generate_base64_audio(text: str) -> str:
    """
    Converts Amharic text to base64-encoded WAV audio.

    Args:
        text (str): Amharic text to convert.

    Returns:
        str: Base64-encoded audio.
    """
    
    # Function to romanize Amharic using uroman
    def uromanize_text(text: str) -> str:
        process = subprocess.Popen(
            ["uroman"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        # Encode input manually as UTF-8
        romanized_text, err = process.communicate(input=text.encode('utf-8'))
        if process.returncode != 0:
            raise RuntimeError(f"Uroman failed: {err.decode('utf-8')}")
        return romanized_text.decode('utf-8').strip()

    # Load model and tokenizer
    model = VitsModel.from_pretrained("facebook/mms-tts-amh")
    tokenizer = AutoTokenizer.from_pretrained("facebook/mms-tts-amh")

    # Input Amharic text
    # text = "ምክንያት"

    # Romanize the text
    romanized_text = uromanize_text(text)

    # Tokenize input
    inputs = tokenizer(romanized_text, return_tensors="pt")

    # Generate waveform
    with torch.no_grad():
        output = model(**inputs).waveform.squeeze()

    # Convert to int16 PCM format
    output_int16 = (output.numpy() * 32767).astype(np.int16)
    # Save to buffer
    buffer = io.BytesIO()
    scipy.io.wavfile.write(buffer, rate=int(model.config.sampling_rate), data=output_int16)
    buffer.seek(0)

    # Encode to base64
    base64_audio = base64.b64encode(buffer.read()).decode("utf-8")
    return base64_audio
