function [output_result, final_image] = run_malnutrition_detector(
    input_img_path,
    output_img_path,
    python_exec_path, % Path to the python executable (e.g., 'C:\Python\python.exe')
    python_script_name, % Name of the script to run ('malnutrition_predictor.py')
    op_list,
    mode % 'PROCESS' or 'PREDICT'
)
    % Core function to run the image processing pipeline and/or ML prediction.
    % It dynamically executes operations defined in the op_list.

    % Initialize output variables to safe defaults
    output_result = 'Error: Function did not complete.';
    final_image = [];

    % Load the image package (required for imread, imresize, etc.)
    pkg load image;

    % --- Step 1: Load Initial Image ---
    try
        current_image = imread(input_img_path);
    catch
        output_result = ['Error: Could not read image from path: ' input_img_path];
        return;
    end

    fprintf(1, 'Starting preprocessing with %d operations...\n', length(op_list));

    % --- Step 2: Apply Operations ---
    for i = 1:length(op_list)
        op_info = op_list{i};
        op_name = op_info{1};
        op_args = op_info(2:end);

        try
            % CRITICAL MAPPING: Determine the correct function name based on the operation short-name.
            if strcmp(op_name, 'brightness_contrast')
                % Mapped to adjust_brightness_contrast.m (uses 'adjust_')
                func_prefix = 'adjust_';
                func_name_suffix = op_name;
            elseif strcmp(op_name, 'otsu')
                % Mapped to apply_otsu_thresholding.m (uses '_thresholding' suffix)
                func_prefix = 'apply_';
                func_name_suffix = 'otsu_thresholding';
            else
                % Default: All others (rotation, dilation) use the 'apply_' prefix
                func_prefix = 'apply_';
                func_name_suffix = op_name;
            end

            % Construct the correct function name string
            func_name = [func_prefix func_name_suffix];

            % Dynamically call the function
            current_image = feval(func_name, current_image, op_args{:});

            fprintf(1, '  - Operation "%s" applied successfully. Image size: [%d %d]\n', ...
                op_name, size(current_image)(1), size(current_image)(2));

        catch
            % If any operation fails, set the error message and stop
            output_result = ['ERROR during operation "' op_name '": ' lasterr()];
            final_image = current_image; % Return image up to failure point
            return;
        end
    end

    % --- Step 3: Set Final Output Image (Used by PROCESS mode preview) ---
    final_image = current_image;

    % --- Step 4: Execute Prediction (Only if mode is 'PREDICT') ---
    if strcmp(mode, 'PREDICT')

        % Ensure image is 224x224 and 3 channels before saving (common ML requirement)
        if size(current_image, 3) == 1
            % Convert grayscale to 3-channel (color model expects color input)
            current_image = cat(3, current_image, current_image, current_image);
        end
        if (size(current_image, 1) ~= 224) || (size(current_image, 2) ~= 224)
            current_image = imresize(current_image, [224 224]);
            final_image = current_image; % Update final image for return
            fprintf(1, 'Image resized to 224x224 for prediction.\n');
        end

        % Save the final processed image for the Python script
        imwrite(current_image, output_img_path);
        fprintf(1, 'Image saved to %s for prediction.\n', output_img_path);

        % Construct the system command using the new path and script name
        command = sprintf('%s "%s" "%s"',
            python_exec_path, ...
            python_script_name, ...
            output_img_path);

        fprintf(1, 'Executing command: %s\n', command);

        % Execute the command and capture output/status
        [status, cmdout] = system(command);

        if status == 0
            % Success: Python script output is the prediction result
            output_result = strtrim(cmdout);
        else
            % Failure: Return detailed error message
            output_result = sprintf('!!! PYTHON ERROR !!!\nPYTHON ERROR: Status %d. Output:\n%s', status, cmdout);
        end
    end

    % --- Step 5: Final Status Update (for PROCESS mode completion) ---
    if strcmp(mode, 'PROCESS') && strcmp(output_result, 'Error: Function did not complete.')
        output_result = ['PROCESS MODE COMPLETE. Final image saved to ' output_img_path];
        % Save the final image here as well, although the test script saves it too.
        imwrite(final_image, output_img_path);
    end

endfunction

