# Malnutrition Detector (Octave GUI)

This project uses a combination of Octave and Python to create a simple graphical interface for detecting malnutrition from facial images.

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
    .\Activate.ps1
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

---


