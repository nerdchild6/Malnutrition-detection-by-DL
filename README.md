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

1.  **Set Octave Directory:**
    * Open the Octave GUI.
    * In the "Current Directory" browser, navigate to the folder where you downloaded this project.

2.  **Configure Python Path:**
    * Open the `malnutrition_detector_octave_gui.m` file in a text editor.
    * Find the `python_executable_path` variable.
    * Change the path to point to the `python.exe` file on your local machine (especially if you are using a virtual environment).

    ```matlab
    % Change this path to match your system's Python executable
    python_executable_path = 'C:\Users\dataEngineer\Desktop\multrition\mulmutrition\Scripts\python.exe';
    ```

### 3. Running the Application

1.  Inside the Octave GUI, open the **Command Window**.
2.  Type the following command and press Enter:

    ```bash
    malnutrition_detector_octave_gui
    ```

3.  The application's GUI should now launch.

---

## 🖼️ Project Gallery

| Main Menu | Image Input | Feature Extraction |
| :---: | :---: | :---: |
| <img width="300" alt="Main menu" src="https://github.com/user-attachments/assets/c4088e2e-5de8-4949-9cba-0f41c5403397" /> | <img width="300" alt="Image input screen" src="https://github.com/user-attachments/assets/e27f0144-a8a2-48f7-875e-229ee91c816a" /> | <img width="300" alt="Feature extraction process" src="https://github.com/user-attachments/assets/00f690bf-87a8-45ac-a3a9-2f0c11fa8188" /> |

| Detection Result (Good) | Detection Result (Poor) |
| :---: | :---: |
| <img width="300" alt="Good nutrition result" src="https://github.com/user-attachments/assets/031748b5-9eb9-43b7-9524-9e3ab5432e76" /> | <img width="300" alt="Poor nutrition result" src="https://github.com/user-attachments/assets/133bb978-7ef7-4d7b-b1a4-8223f215b56b" /> |

