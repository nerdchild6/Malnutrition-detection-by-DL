# Smart Image Processing Toolbox for Malnutrition Detection

This repository contains the source code for the university project: **Malnutrition Detection using Deep Learning or ML**. It serves as a proof-of-concept for building a robust, modular Image Processing Toolbox in **GNU Octave** and integrating it with a **Python/TensorFlow** backend for specialized deep learning inference.

## 🌟 Overview & Core Objectives

The goal was to create a flexible, user-friendly graphical interface (GUI) that enables users to construct a custom image processing pipeline and apply it to a complex classification task.

### Key Deliverables:

1. **Comprehensive Toolbox:** Implementation of **13 core image processing functions** across Enhancement, Segmentation, and Geometric modules.

2. **Hybrid Architecture:** Establishing a reliable communication bridge between the Octave frontend and the Python ML environment.

3. **State Management:** Developing a system to prevent pipeline crashes due to data type and channel mismatches (e.g., color operation following grayscale).

## 💻 System Architecture

The project utilizes a **Hybrid Model** (Octave ↔ Python) to maximize performance and flexibility while meeting the project's technological constraints.

| Component | Technology | Primary Role | 
| ----- | ----- | ----- | 
| **Frontend/GUI** | GNU Octave (`.m` files) | User interaction, pipeline construction, visualization. | 
| **Toolbox Core** | GNU Octave (13 functions) | Executes preprocessing steps (e.g., Filtering, Rotation). | 
| **Inter-Process Bridge** | Octave `system()` command (`run_malnutrition_detector.m`) | Serializes the processing chain into JSON and executes the Python script. | 
| **ML Backend** | Python 3, TensorFlow/Keras | Loads the CNN model (`.h5`), runs inference, and returns the classification result. | 

## 🛠️ Implemented Toolbox Features (13 Functions)

The GUI allows users to combine any of these 13 functions sequentially:

| Module | Operation Code (Used in Pipeline) | Function File | 
| ----- | ----- | ----- | 
| **Enhancement** | `brightness_contrast` | `adjust_brightness_contrast.m` | 
|  | `hist_equalization` | `apply_hist_equalization.m` | 
|  | `laplacian_sharpening` | `apply_laplacian_sharpening.m` | 
|  | `mean_filter`, `median_filter` | `apply_mean_filter.m`, `apply_median_filter.m` | 
| **Segmentation** | `otsu_thresholding` | `apply_otsu_thresholding.m` | 
|  | `canny_edge_detection` | `apply_canny_edge_detection.m` | 
|  | `color_segmentation` | `apply_color_segmentation.m` | 
|  | `dilation`, `erosion` | `apply_dilation.m`, `apply_erosion.m` | 
| **Geometric** | `rotation`, `cropping`, `resizing` | `apply_rotation.m`, `apply_cropping.m`, `apply_resizing.m` | 

### **Feature Highlight: Robust State Management**

To prevent the pipeline from crashing when a color-based operation (like `color_segmentation`) follows a grayscale operation (like `otsu_thresholding`), it will show the caution message for maintaining pipeline integrity.

---

## 🚀 Getting Started

Follow these instructions to set up and run the project on your local machine.

### 1. Prerequisites

You must have the following software installed:

* **Octave GUI:** Version 10.2
* **Python:** Version 3.13.7

### 2. Configuration

1.  **Create your python environment**
    * Open the  **Windows (PowerShell)** on this project's directory and run this command:
    ```bash
    python -m venv my_env
    ```
    * Run this command for activate environment:
    ```bash
    .\my_env\Scripts\Activate.ps1
    ```
    * Run this command for install dependencies
    ```bash
    pip install -r requirements.txt
    ```
2.  **Set Octave Directory:**
    * Open the Octave GUI.
    * In the "Current Directory" browser, navigate to the folder where you downloaded this project.

| Step1 | Step2 | Step3|
| :---: | :---: | :---: |
| <img width="300" alt="Feature extraction process" src="https://github.com/user-attachments/assets/00f690bf-87a8-45ac-a3a9-2f0c11fa8188" /> | <img width="300" alt="Good nutrition result" src="https://github.com/user-attachments/assets/031748b5-9eb9-43b7-9524-9e3ab5432e76" /> | <img width="300" alt="Poor nutrition result" src="https://github.com/user-attachments/assets/133bb978-7ef7-4d7b-b1a4-8223f215b56b" /> |

2.  **Configure Python Environment Path:**
    * Open the `malnutrition_detector_octave_gui.m` file in a text editor.
    * Find the `python_executable_path` variable.
    * Change the path to point to the `python.exe` file on your local machine (especially if you are using a virtual environment) that you have created.

    ```matlab
    % Change this path to match your system's Python executable
    python_executable_path = 'C:\Users\dataEngineer\Desktop\Malnutrition-detection-by-DL\my_env\Scripts\python.exe';
    ```

### 3. Running the Application

1.  Inside the Octave GUI, open the **Command Window**.
2.  Type the following command and press Enter:

    ```bash
    malnutrition_detector_octave_gui
    ```
3.  The application's GUI should now launch.
<img width="960" height="505" alt="image" src="https://github.com/user-attachments/assets/6e09bc5b-ffcf-4408-a422-9750c9ce32ad" />

---
## 👥 Project Structure & Team Roles

This project was developed by a team focused on integrating **classical image processing techniques (Octave)** with **modern deep learning (Python)** to create a robust diagnostic prototype.

---

### 🎨 Frontend GUI & Integration Engineer — [Worrawit Klangsaeng]

- **`malnutrition_detector_octave_gui.m`**  
  The main application interface and Octave GUI structure.

- **`run_malnutrition_detector.m`**  
  The core integration script responsible for:
  - Managing the processing pipeline state  
  - Orchestrating the system call to the Python inference module  

---

### ⚙️ Image Processing Engineer — [Thareerat Jarungruk]

- **All 13 `.m` files** (e.g., `adjust_brightness_contrast.m`, `apply_rotation.m`, etc.)  
  Implements the complete set of **13 core image processing functions** across:
  - Enhancement Module  
  - Segmentation Module  
  - Geometric Module  
---

### 🧠 Machine Learning & Inference Engineer — [Thanapat Nasa]

- **`malnutrition_predictor.py`**  
  Python-based inference script responsible for:
  - Reading the processed image  
  - Running the trained ML model  
  - Outputting the final classification string  

- **`trained_malnutrition_model.h5`**  
  Pre-trained **Keras/MobileNetV2** deep learning model used for malnutrition classification.

- **`requirements.txt`**  
  Lists all required Python dependencies (TensorFlow, Keras, NumPy, etc.) for the ML environment.



