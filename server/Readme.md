# Hand Detection API

A FastAPI backend that processes uploaded images to detect hands using MediaPipe and returns landmarks and ROI info.

## 🚀 Features
- Accepts image uploads via POST endpoint.
- Uses MediaPipe Hand Landmarker to detect hands.
- Returns landmarks and bounding box info.

## 🗂️ Project Structure

```bash
hand_detection_api/
├── app/
│   ├── main.py
│   ├── routes/
│   │   └── image_processing.py
│   ├── services/
│   │   └── mediapipe_service.py
│   ├── models/
│   └── utils/
├── hand_landmarker.task
├── requirements.txt
├── README.md
└── venv/
```

## 📦 Installation

This section explains how to get the project up and running on your local machine.

### 1️⃣ Clone the repository

Clone the repository to your local machine using the following command:

```bash
git clone <your-repo-url>
cd hand_detection_api
```


### 2️⃣ Set up a virtual environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows use `venv\Scripts\activate`
```
### 3️⃣ Install dependencies
```bash
pip install -r requirements.txt
```

### 4️⃣ Run the application
```bash
uvicorn app.main:app --reload
```

Then visit: http://127.0.0.1:8000/docs to see the API documentation and test the endpoints.