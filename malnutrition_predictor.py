import sys
import os
import numpy as np
import pandas as pd
from PIL import Image
from tensorflow.keras.models import load_model

# --- 1. Configuration Constants ---
MODEL_PATH = 'trained_malnutrition_model.h5'
IMG_SIZE = 224
TRAIN_CSV = '_annotations_train.csv'
CLASS_LABELS = ['Healthy', 'Malnourished']  # default fallback

# --- 2. Load class labels dynamically (to match training order) ---
def get_class_labels(csv_path):
    """Read the training CSV to get consistent class label order used during model training."""
    try:
        df = pd.read_csv(csv_path)
        labels = sorted(df['class'].unique())
        return labels
    except Exception:
        return ['Healthy', 'Malnourished']


def run_prediction():
    """Prediction function consistent with MobileNetV2 softmax output (multi-class)."""
    if len(sys.argv) < 2:
        print("ERROR: Missing image path argument.", file=sys.stderr)
        sys.exit(1)

    image_path = sys.argv[1]

    # Load class labels from CSV
    global CLASS_LABELS
    CLASS_LABELS = get_class_labels(TRAIN_CSV)

    try:
        # --- Load trained model ---
        if not os.path.exists(MODEL_PATH):
            print(f"ERROR: Model file not found at {MODEL_PATH}", file=sys.stderr)
            sys.exit(1)

        model = load_model(MODEL_PATH)

        # --- Preprocess image ---
        img = Image.open(image_path).convert('RGB')
        if img.size != (IMG_SIZE, IMG_SIZE):
            img = img.resize((IMG_SIZE, IMG_SIZE))

        img_array = np.array(img).astype('float32') / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        # --- Predict (model uses softmax for categorical classification) ---
        predictions = model.predict(img_array, verbose=0)[0]

        # --- Get predicted class ---
        predicted_index = np.argmax(predictions)
        if predicted_index >= len(CLASS_LABELS):
            result = "UNKNOWN"
            confidence = 0
        else:
            result = CLASS_LABELS[predicted_index]
            confidence = predictions[predicted_index] * 100

        # --- Print output for Octave integration ---
        print(f"{result} ({confidence:.2f}%)")

    except Exception as e:
        print(f"ERROR: Model prediction failed. Details: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    run_prediction()
