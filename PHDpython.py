import sys
import os
import numpy as np
from PIL import Image
# Use standard Keras/TensorFlow imports
from tensorflow.keras.models import load_model

# --- 1. Configuration Constants ---
# NOTE: These constants MUST match the model training parameters exactly.
MODEL_PATH = 'trained_malnutrition_model.h5'
IMG_SIZE = 224

# Define class labels explicitly to avoid external file dependency during runtime
# 0 = Healthy, 1 = Malnourished (based on alphabetical sorting if Keras trained on folder names)
CLASS_LABELS = ['Healthy', 'Malnourished']

def run_prediction():
    """
    Loads the trained model, preprocesses the input image (provided by Octave),
    and prints the prediction result to standard output.
    """
    # Check if the image path was passed as an argument
    if len(sys.argv) < 2:

        # Print error message to stderr (not stdout, which is reserved for the result)
        print("ERROR: Missing image path argument. Please provide a path to the 224x224 input image.", file=sys.stderr)
        sys.exit(1)

    image_path = sys.argv[1]

    try:
        # 2. Load the trained model
        if not os.path.exists(MODEL_PATH):
            print(f"ERROR: Model file not found at {MODEL_PATH}", file=sys.stderr)
            sys.exit(1)

        model = load_model(MODEL_PATH)

        # 3. Load and Preprocess Image (Octave should ensure it's 224x224, but we verify)
        # Open the image file
        img = Image.open(image_path).convert('RGB')

        # MANDATORY: Resize the image to 224x224 to match model input size
        if img.size != (IMG_SIZE, IMG_SIZE):
             img = img.resize((IMG_SIZE, IMG_SIZE))

        # Convert to Array
        img_array = np.array(img).astype('float32')

        # MANDATORY: Normalize pixel values (0-255 -> 0-1)
        # Assuming the model was trained with 1./255 rescaling.
        img_array = img_array / 255.0

        # Add batch dimension (1, 224, 224, 3)
        img_array = np.expand_dims(img_array, axis=0)

        # 4. Predict
        # The model uses sigmoid output layer for binary classification (0 or 1).
        # We assume the model outputs a single value between 0 and 1.
        prediction_value = model.predict(img_array, verbose=0)[0][0]

        # 5. Determine Class and Confidence
        # If prediction_value > 0.5, it's class 1 ('Malnourished').
        if prediction_value >= 0.5:
            result = CLASS_LABELS[1]  # 'Malnourished'
            confidence = prediction_value * 100
        else:
            result = CLASS_LABELS[0]  # 'Healthy'
            # Confidence for the 'Healthy' class
            confidence = (1 - prediction_value) * 100

        # 6. Print the result to Standard Output (for Octave to read)
        # Format: [Class] ([Confidence]%)
        print(f"{result} ({confidence:.2f}%)")

    except Exception as e:

        # Catch and report any other runtime errors
        print(f"ERROR: Model prediction failed. Details: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":

    run_prediction()