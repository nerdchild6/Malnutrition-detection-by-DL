% This script runs the full malnutrition detection pipeline in two phases
% to test all 13 preprocessing functions implemented by the user.

clear all;
close all;
pkg load image;
addpath('.'); % Ensure current directory is in the path

% --- User Configuration (MANDATORY) ---
% !!! CHANGE THIS TO YOUR ACTUAL PYTHON.EXE PATH !!!
python_executable_path = 'C:\Users\dataEngineer\Desktop\multrition\mulmutrition\Scripts\python.exe';
input_img_path = 'test_image.jpg'; % Ensure this file exists for testing
output_img_path = 'processed_output.png';
python_script_name = 'malnutrition_predictor.py'; % The Python script name

% Create a dummy test image if one doesn't exist
if exist(input_img_path, 'file') ~= 2
    fprintf(2, 'WARNING: Test image %s not found. Creating a dummy 224x224 RGB image.\n', input_img_path);
    img = uint8(rand(224, 224, 3) * 255);
    imwrite(img, input_img_path);
end
% -------------------------------------------------------------------------

% --- Phase 1: Operations that can handle/output Grayscale/Binary (11 Ops) ---
op_list_phase1 = {
    % [op_function_name, param1, param2, ...]
    {'brightness_contrast', 50, 1.5};       % Mapped to adjust_brightness_contrast
    {'rotation', 45};                       % Mapped to apply_rotation
    {'otsu_thresholding'};                  % Mapped to apply_otsu_thresholding
    {'dilation', 3};                        % Mapped to apply_dilation
    {'erosion', 3};                         % Mapped to apply_erosion
    {'mean_filter', 5};                     % Mapped to apply_mean_filter
    {'median_filter', 5};                   % Mapped to apply_median_filter
    {'hist_equalization'};                  % Mapped to apply_hist_equalization
    {'canny_edge_detection', 0.1, 0.5};     % Mapped to apply_canny_edge_detection
    {'laplacian_sharpening'};               % Mapped to apply_laplacian_sharpening
    {'resizing', 230, 230, 'bilinear'};     % Mapped to apply_resizing (Height, Width, Method)
};

% --- Phase 2: Color and Spatial Operations (Require original RGB input - 2 Ops) ---
op_list_phase2 = {
    {'color_segmentation', {0.1, 0.3, 0.2, 0.8}}; % Mapped to apply_color_segmentation (HueMin, HueMax, SatMin, SatMax)
    {'cropping', 10, 10, 200, 200};             % Mapped to apply_cropping (X, Y, Width, Height)
};

% -------------------------------------------------------------------------
% NOTE: The calls below match your run_malnutrition_detector.m signature:
% function [output_result, final_image] = run_malnutrition_detector(
%   input_img_path, output_img_path, python_exec_path, python_script_name, op_list, mode)
% -------------------------------------------------------------------------

fprintf('\n--- Running All Tests ---\n');

% --- TEST 1: Process Mode with Phase 1 Operations ---
fprintf('\n--- Starting Test 1 (Phase 1 Operations - %d Ops) in PROCESS Mode ---\n', length(op_list_phase1));
[output_status_p1, ~] = run_malnutrition_detector(input_img_path, output_img_path, python_executable_path, python_script_name, op_list_phase1, 'PROCESS');
fprintf('PROCESS Mode Status (Phase 1): %s\n', output_status_p1);

% --- TEST 2: Prediction Mode with Phase 1 Operations ---
fprintf('\n--- Starting Test 2 (Phase 1 Operations - %d Ops) in PREDICT Mode ---\n', length(op_list_phase1));
[prediction_result_p1, ~] = run_malnutrition_detector(input_img_path, output_img_path, python_executable_path, python_script_name, op_list_phase1, 'PREDICT');
fprintf('PREDICTION Mode Result (Phase 1): %s\n', prediction_result_p1);

% -------------------------------------------------------------------------

% --- TEST 3: Process Mode with Phase 2 Operations (Using Original Input) ---
fprintf('\n--- Starting Test 3 (Phase 2 Operations - %d Ops) in PROCESS Mode ---\n', length(op_list_phase2));
[output_status_p2, ~] = run_malnutrition_detector(input_img_path, output_img_path, python_executable_path, python_script_name, op_list_phase2, 'PROCESS');
fprintf('PROCESS Mode Status (Phase 2): %s\n', output_status_p2);

% --- TEST 4: Prediction Mode with Phase 2 Operations (Using Original Input) ---
fprintf('\n--- Starting Test 4 (Phase 2 Operations - %d Ops) in PREDICT Mode ---\n', length(op_list_phase2));
[prediction_result_p2, ~] = run_malnutrition_detector(input_img_path, output_img_path, python_executable_path, python_script_name, op_list_phase2, 'PREDICT');
fprintf('PREDICTION Mode Result (Phase 2): %s\n', prediction_result_p2);

fprintf('\n--- Full 13-Function Test Complete ---\n');


