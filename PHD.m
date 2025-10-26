function malnutrition_detector_octave_gui()
    % --- Configuration (User MUST update these paths) ---
    % NOTE: Paths are retained from your input but must be correct for Octave to run Python.
    python_executable_path = 'C:\Users\dataEngineer\Desktop\multrition\mulmutrition\Scripts\python.exe';
    python_script_name = 'malnutrition_predictor.py';

    % --- Global Variables for GUI state ---
    global app_data;
    app_data.current_image = [];
    app_data.processed_image = [];
    app_data.image_path = '';
    app_data.op_list = {}; % Stores the list of selected operations
    app_data.python_exec = python_executable_path;
    app_data.python_script = python_script_name;

    % --- GUI Setup ---
    fig_width = 1300;
    fig_height = 720;
    h_fig = figure('name', 'Malnutrition Detector & Image Toolbox', ...
        'position', [100 100 fig_width fig_height], ...
        'menubar', 'none', ...
        'toolbar', 'none', ...
        'NumberTitle', 'off', ...
        'Color', [0.94 0.94 0.97]);

    % === SCROLLABLE CONTROL PANEL (Left) ===
    panel_width = 360;
    panel_color = [0.96 0.96 0.96];

    % 1. Outer Panel (Viewport) - This acts as the clipping boundary (95% height)
    outer_panel_width_normalized = panel_width/fig_width;
    h_outer_panel = uipanel('Parent', h_fig, ...
        'Title', 'Control Panel (Scrollable)', ...
        'FontWeight', 'bold', ...
        'BackgroundColor', panel_color, ...
        'Units', 'normalized', ...
        'Position', [0.01 0.05 outer_panel_width_normalized 0.9]);

    % 2. Inner Panel (Content Holder) - This is 200% the height of the viewport
    inner_panel_height = 2.0;

    % Initialize Y to 0. This shows the TOP content, matching slider Value=1.
    h_inner_panel = uipanel('Parent', h_outer_panel, ...
        'BorderType', 'none', ...
        'Units', 'normalized', ...
        'Position', [0, 0, 0.95, inner_panel_height]);

    % 3. Vertical Slider (Scrollbar)
    h_slider = uicontrol('Parent', h_outer_panel, 'Style', 'slider', ...
        'Units', 'normalized', ...
        'Position', [0.95, 0, 0.05, 1], ...
        'Min', 0, 'Max', 1, 'Value', 1, ... % Value=1 sets it to the top initially
        'Callback', {@slider_callback, h_inner_panel, inner_panel_height});

    % Set initial scroll position (calls the callback once)
    slider_callback(h_slider, [], h_inner_panel, inner_panel_height);


    % --- INTERNAL CONTROL PLACEMENT (INSIDE h_inner_panel) ---
    % Y positions are relative to the INNER PANEL (height 2.0)

    % STARTING POSITION ADJUSTMENT (To clear the panel title bar)
    y_pos = 1.00; % Start near the top of the 2.0 height
    control_parent = h_inner_panel;

    % --- Define new, smaller dimensions ---
    control_h = 0.035; % Height for buttons/popups
    control_v_spacing = 0.01; % Spacing between controls
    section_v_spacing = 0.04; % Used to separate major sections

    % --- Section 1: Image Loading ---
    % The status of loading will now be reported in the result text field.
    uicontrol('Parent', control_parent, 'Style', 'pushbutton', ...
        'String', '1. Load Image', ...
        'Units', 'normalized', ...
        'Position', [0.05 y_pos-control_h 0.9 control_h], ...
        'FontWeight', 'bold', ...
        'Callback', @load_image_callback);
    % We remove the text field space, and simply move to the next section
    y_pos = y_pos - (control_h + section_v_spacing);

    % --- Section 2: Operation Pipeline ---
    uicontrol('Parent', control_parent, 'Style', 'text', ...
        'String', '2. Select Operations (Pipeline):', ...
        'Units', 'normalized', ...
        'Position', [0.05 y_pos-control_h 0.9 control_h], ...
        'HorizontalAlignment', 'left', ...
        'FontSize', 10, ... % Slightly smaller font
        'FontWeight', 'bold', ...
        'BackgroundColor', panel_color);
    y_pos = y_pos - (control_h + control_v_spacing);

    % --- Add operation controls ---

    op_names = {'brightness_contrast','rotation','otsu_thresholding','dilation', ...
                'erosion','mean_filter','median_filter','hist_equalization', ...
                'canny_edge_detection','laplacian_sharpening','color_segmentation','cropping'};
    app_data.h_op_menu = uicontrol('Parent', control_parent, ...
        'Style', 'popupmenu', ...
        'String', op_names, ...
        'Units', 'normalized', ...
        'Position', [0.05 y_pos-control_h 0.62 control_h], ...
        'FontSize', 9, ...
        'Callback', @op_menu_callback);

    uicontrol('Parent', control_parent, 'Style', 'pushbutton', ...
        'String', 'Add', ...
        'Units', 'normalized', ...
        'Position', [0.69 y_pos-control_h 0.26 control_h], ...
        'FontSize', 9, ...
        'Callback', @add_operation_callback);
    y_pos = y_pos - (control_h + control_v_spacing);

    % --- Remove Operation Button (Restored) ---
    uicontrol('Parent', control_parent, 'Style', 'pushbutton', ...
        'String', 'Remove Selected Operation', ...
        'Units', 'normalized', ...
        'Position', [0.05 y_pos-control_h 0.9 control_h], ...
        'FontSize', 9, ...
        'Callback', @remove_operation_callback);
    y_pos = y_pos - (control_h + section_v_spacing);

    % --- Parameter input area ---
    param_panel_height = 0.22; % Reduced from 0.30
    h_param_panel = uipanel('Parent', control_parent, ...
        'Title', 'Operation Parameters', ...
        'FontSize', 9, ... % Smaller font for panel title
        'BackgroundColor', [0.98 0.98 0.98], ...
        'Units', 'normalized', ...
        'Position', [0.05 y_pos-param_panel_height 0.9 param_panel_height]);

    % Adjusted relative positioning inside the parameter panel (0 to 1)
    param_y = 0.85;
    param_h = 0.12; % Reduced height
    param_spacing = 0.02; % Reduced spacing

    for i = 1:4
        app_data.(['h_param_label_' num2str(i)]) = uicontrol('Parent', h_param_panel, ...
            'Style', 'text', ...
            'String', ['Param ' num2str(i) ':'], ...
            'Units', 'normalized', ...
            'Position', [0.05 param_y-param_h 0.45 param_h], ...
            'HorizontalAlignment', 'left', ...
            'FontSize', 8, ...
            'BackgroundColor', [0.98 0.98 0.98], ...
            'Visible', 'off');
        app_data.(['h_param_input_' num2str(i)]) = uicontrol('Parent', h_param_panel, ...
            'Style', 'edit', ...
            'String', '', ...
            'Units', 'normalized', ...
            'Position', [0.52 param_y-param_h 0.43 param_h], ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 8, ...
            'BackgroundColor', [1 1 1], ...
            'Visible', 'off');
        param_y = param_y - (param_h + param_spacing);
    end
    y_pos = y_pos - (param_panel_height + control_v_spacing);

    % --- Operations list ---
    op_list_height = 0.22; % Reduced from 0.30
    app_data.h_op_listbox = uicontrol('Parent', control_parent, ...
        'Style', 'listbox', ...
        'String', {}, ...
        'Units', 'normalized', ...
        'Position', [0.05 y_pos-op_list_height 0.9 op_list_height], ...
        'BackgroundColor', [0.9 0.9 1], ...
        'FontSize', 9, ...
        'TooltipString', 'List of operations in sequence');
    y_pos = y_pos - (op_list_height + control_v_spacing);

    % --- Run buttons ---
    run_btn_h = 0.05;
    uicontrol('Parent', control_parent, 'Style', 'pushbutton', ...
        'String', '3. Run Processing (Preview)', ...
        'Units', 'normalized', ...
        'Position', [0.05 y_pos-run_btn_h 0.9 run_btn_h], ...
        'FontWeight', 'bold', ...
        'FontSize', 10, ...
        'BackgroundColor', [0.8 1.0 0.8], ...
        'Callback', @run_processing_callback);
    y_pos = y_pos - (run_btn_h + control_v_spacing);

    uicontrol('Parent', control_parent, 'Style', 'pushbutton', ...
        'String', '4. Run Prediction (ML/DL)', ...
        'Units', 'normalized', ...
        'Position', [0.05 y_pos-run_btn_h 0.9 run_btn_h], ...
        'FontWeight', 'bold', ...
        'FontSize', 10, ...
        'BackgroundColor', [1.0 0.8 0.8], ...
        'Callback', @run_prediction_callback);
    y_pos = y_pos - (run_btn_h + control_v_spacing);

    result_text_h = 0.07;
    app_data.h_result_text = uicontrol('Parent', control_parent, ...
        'Style', 'text', ...
        'String', 'Prediction Result: Awaiting run.', ...
        'Units', 'normalized', ...
        'Position', [0.05 y_pos-result_text_h 0.9 result_text_h], ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [1 1 1], ...
        'HorizontalAlignment', 'left');
    % Final Y position is now higher up in the inner panel.


    % === Image Display Panels ===
    app_data.h_axes_original = axes('Parent', h_fig, 'Units', 'normalized', ...
        'Position', [0.32 0.08 0.33 0.85]);
    axis(app_data.h_axes_original, 'off');
    title(app_data.h_axes_original, 'Original Image', 'FontWeight', 'bold');

    app_data.h_axes_processed = axes('Parent', h_fig, 'Units', 'normalized', ...
        'Position', [0.66 0.08 0.33 0.85]);
    axis(app_data.h_axes_processed, 'off');
    title(app_data.h_axes_processed, 'Processed / Prediction Input', 'FontWeight', 'bold');

    % Initialize
    update_op_listbox();
    op_menu_callback();
end

% ----------------------------------------------------------------------
% --- Scrollbar Callback Function (Corrected and Simplified) ---
% ----------------------------------------------------------------------
function slider_callback(src, ~, panelHandle, H)
    % H: inner panel height (2.0)
    v = get(src, 'Value');

    % Total scroll range = H - 1 (1.0 in this case).
    newY = v * (1 - H);

    set(panelHandle, 'Position', [0, newY, 0.95, H]);
end

% ----------------------------------------------------------------------
% --- Helper Functions (Cont.) ---
% ----------------------------------------------------------------------

function update_op_listbox()
    global app_data;
    op_display = {};
    for i = 1:length(app_data.op_list)
        op = app_data.op_list{i};
        op_name = op{1};
        op_args = op(2:end);
        arg_str = '';
        for j = 1:length(op_args)
            current_arg = op_args{j};
            % Handle nested cell arrays for complex arguments
            if iscell(current_arg)
                nested_str = ['{' sprintf('%.2f,', cell2mat(current_arg)) '}'];
                arg_str = [arg_str ' | ' nested_str(1:end-2) '}'];
            elseif isnumeric(current_arg)
                % If integer, display as integer, otherwise float
                if current_arg == round(current_arg)
                    arg_str = [arg_str ' | ' sprintf('%d', current_arg)];
                else
                    arg_str = [arg_str ' | ' sprintf('%.2f', current_arg)];
                end
            elseif ischar(current_arg)
                arg_str = [arg_str ' | ' current_arg];
            end
        end
        op_display{i} = [num2str(i) ': ' op_name arg_str];
    end
    set(app_data.h_op_listbox, 'string', op_display);
    % Check if the listbox needs to be updated after removal
    if length(app_data.op_list) == 0
        set(app_data.h_op_listbox, 'value', 0);
    end
end

function plot_image(h_axes, img, title_str)
    % Helper function to display an image in the specified axes
    axes(h_axes);
    if isempty(img)
        cla(h_axes);
        title(h_axes, title_str);
    else
        imshow(img, 'parent', h_axes);
        title(h_axes, title_str);
    end
    axis(h_axes, 'off');
end

function update_parameter_inputs(params_to_show, default_values)
    global app_data;
    % Hide all 4 parameter controls first
    for i = 1:4
        set(app_data.(['h_param_label_' num2str(i)]), 'visible', 'off');
        set(app_data.(['h_param_input_' num2str(i)]), 'visible', 'off');
        set(app_data.(['h_param_input_' num2str(i)]), 'string', ''); % Clear value
    end
    % Show and set properties for required parameters
    num_params = length(params_to_show);
    for i = 1:num_params
        label_handle = app_data.(['h_param_label_' num2str(i)]);
        input_handle = app_data.(['h_param_input_' num2str(i)]);
        set(label_handle, 'string', [params_to_show{i} ':'], 'visible', 'on');
        set(input_handle, 'string', default_values{i}, 'visible', 'on');
    end
end

function op_menu_callback(~, ~)
    global app_data;
    op_names = get(app_data.h_op_menu, 'string');
    selected_index = get(app_data.h_op_menu, 'value');
    selected_op_name = op_names{selected_index};

    % Define the required parameters and default values for each operation
    switch selected_op_name
        case 'brightness_contrast'
            update_parameter_inputs({'Brightness (Int)', 'Contrast (Float)'}, {'50', '1.5'});
        case 'rotation'
            update_parameter_inputs({'Angle (Degrees)'}, {'45'});
        case {'dilation', 'erosion', 'mean_filter', 'median_filter'}
            update_parameter_inputs({'Kernel Size (Int)'}, {'5'});
        case 'canny_edge_detection'
            update_parameter_inputs({'Low Threshold (Float)', 'High Threshold (Float)'}, {'0.1', '0.5'});
        case 'cropping'
            update_parameter_inputs({'Start X (Int)', 'Start Y (Int)', 'Width (Int)', 'Height (Int)'}, {'100', '100', '200', '200'});
        case 'color_segmentation'
            update_parameter_inputs({'Hue Min (0-1.0)', 'Hue Max (0-1.0)', 'Sat Min (0-1.0)', 'Sat Max (0-1.0)'}, {'0.0', '0.3', '0.2', '0.8'});
        case {'otsu_thresholding', 'hist_equalization', 'laplacian_sharpening'}
            update_parameter_inputs({}, {});
        otherwise
            update_parameter_inputs({}, {});
    end
    set(app_data.h_result_text, 'string', ['Ready to add: ' selected_op_name], 'BackgroundColor', [1 1 1]);
end

% ----------------------------------------------------------------------
% --- Callback Functions (Cont.) ---
% ----------------------------------------------------------------------

function load_image_callback(~, ~)
    global app_data;
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'}, 'Select an Image File');
    if filename
        app_data.image_path = fullfile(pathname, filename);
        try
            app_data.current_image = imread(app_data.image_path);
            % Status moved to result text
            set(app_data.h_result_text, 'string', ['Image Loaded: ' filename], 'BackgroundColor', [0.7 1 0.7]);
            plot_image(app_data.h_axes_original, app_data.current_image, 'Original Image');
            plot_image(app_data.h_axes_processed, [], 'Processed Image');
        catch
            set(app_data.h_result_text, 'string', 'Error loading image! Check file format.', 'BackgroundColor', [1 0.7 0.7]);
            app_data.current_image = [];
        end
    end
end

function add_operation_callback(~, ~)
    global app_data;
    op_names = get(app_data.h_op_menu, 'string');
    selected_index = get(app_data.h_op_menu, 'value');
    selected_op_name = op_names{selected_index};
    op_info = {};
    op_params = {};
    is_valid = true;
    error_msg = '';

    % Helper function to read a parameter and check if it's visible
    function [val, is_present] = read_param(index)
        input_handle = app_data.(['h_param_input_' num2str(index)]);
        if strcmp(get(input_handle, 'visible'), 'on')
            str_val = get(input_handle, 'string');
            num_val = str2num(str_val);
            if isempty(str_val) || isempty(num_val) || !isscalar(num_val)
                val = NaN;
                is_present = true;
            else
                val = num_val;
                is_present = true;
            end
        else
            val = NaN;
            is_present = false;
        end
    end

    % --- DYNAMIC PARAMETER READING ---
    try
        switch selected_op_name
            case 'brightness_contrast'
                [brightness, is_b_present] = read_param(1);
                [contrast, is_c_present] = read_param(2);
                if isnan(brightness) || isnan(contrast)
                    is_valid = false;
                    error_msg = 'ERROR: Brightness and Contrast must be valid numbers.';
                else
                    op_params = {brightness, contrast};
                end
            case 'rotation'
                [angle, is_present] = read_param(1);
                if isnan(angle) || !is_present
                    is_valid = false;
                    error_msg = 'ERROR: Rotation Angle must be a valid number.';
                else
                    op_params = {angle};
                end
            case {'dilation', 'erosion', 'mean_filter', 'median_filter'}
                [kernel, is_present] = read_param(1);
                if isnan(kernel) || !is_present || kernel <= 0 || kernel ~= round(kernel)
                    is_valid = false;
                    error_msg = 'ERROR: Kernel Size must be a positive integer.';
                % Note: Octave's logical NOT is `!`, not `~` as in MATLAB
                else
                    op_params = {kernel};
                end
            case 'canny_edge_detection'
                [low_thresh, is_low_present] = read_param(1);
                [high_thresh, is_high_present] = read_param(2);
                if isnan(low_thresh) || isnan(high_thresh) || high_thresh <= low_thresh
                    is_valid = false;
                    error_msg = 'ERROR: Canny thresholds must be valid numbers, and High must be > Low.';
                else
                    op_params = {low_thresh, high_thresh};
                end
            case 'cropping'
                [x, ~] = read_param(1);
                [y, ~] = read_param(2);
                [w, ~] = read_param(3);
                [h, ~] = read_param(4);
                if isnan(x) || isnan(y) || isnan(w) || isnan(h) || w <= 0 || h <= 0
                    is_valid = false;
                    error_msg = 'ERROR: Cropping parameters must be valid positive numbers.';
                else
                    op_params = {x, y, w, h};
                end
            case 'color_segmentation'
                [h_min, ~] = read_param(1);
                [h_max, ~] = read_param(2);
                [s_min, ~] = read_param(3);
                [s_max, ~] = read_param(4);
                if isnan(h_min) || isnan(h_max) || isnan(s_min) || isnan(s_max) || h_max < h_min || s_max < s_min
                    is_valid = false;
                    error_msg = 'ERROR: Color parameters must be valid numbers (0.0-1.0) and Max > Min.';
                else
                    op_params = {{h_min, h_max, s_min, s_max}};
                end
            case {'otsu_thresholding', 'hist_equalization', 'laplacian_sharpening'}
                op_params = {};
            otherwise
                op_params = {};
        end
    catch
        is_valid = false;
        error_msg = 'ERROR: An unexpected error occurred reading parameters.';
    end
    % --- END DYNAMIC PARAMETER READING ---

    if is_valid
        op_info = {selected_op_name, op_params{:}};
        app_data.op_list{end+1} = op_info;
        update_op_listbox();
        set(app_data.h_op_listbox, 'value', length(app_data.op_list));
        set(app_data.h_result_text, 'string', ['Added operation: ' selected_op_name], 'BackgroundColor', [0.7 1 0.7]);
    else
        set(app_data.h_result_text, 'string', error_msg, 'BackgroundColor', [1 0.7 0.7]);
    end
end

function remove_operation_callback(~, ~)
    global app_data;
    selected_item = get(app_data.h_op_listbox, 'value');

    if length(app_data.op_list) == 0
        set(app_data.h_result_text, 'string', 'No operations to remove.', 'BackgroundColor', [1.0 0.9 0.7]);
        return;
    end

    if ~isempty(selected_item) && selected_item <= length(app_data.op_list) && selected_item > 0
        % Remove the selected item
        app_data.op_list(selected_item) = [];

        % Adjust the selection value for the listbox
        new_value = selected_item;
        if new_value > length(app_data.op_list) && length(app_data.op_list) > 0
             % If the last item was removed, select the new last item
            new_value = length(app_data.op_list);
        elseif length(app_data.op_list) == 0
            % If the list is empty, clear selection
            new_value = 0;
        end

        set(app_data.h_op_listbox, 'value', new_value);
        update_op_listbox();
        set(app_data.h_result_text, 'string', 'Removed selected operation.', 'BackgroundColor', [1 1 1]);
    else
        set(app_data.h_result_text, 'string', 'Please select an operation to remove.', 'BackgroundColor', [1.0 0.9 0.7]);
    end
end

function run_processing_callback(~, ~)
    global app_data;
    if isempty(app_data.current_image)
        set(app_data.h_result_text, 'string', 'ERROR: Load an image first!', 'BackgroundColor', [1 0.7 0.7]);
        return;
    end
    if isempty(app_data.op_list)
        set(app_data.h_result_text, 'string', 'ERROR: Add operations first!', 'BackgroundColor', [1 0.7 0.7]);
        return;
    end

    set(app_data.h_result_text, 'string', 'Processing in progress...', 'BackgroundColor', [1 1 0.7]);
    drawnow;

    output_path = 'temp_gui_processed.png';

    [result_status, processed_img] = run_malnutrition_detector( ...
        app_data.image_path, ...
        output_path, ...
        app_data.python_exec, ...
        app_data.python_script, ...
        app_data.op_list, ...
        'PROCESS' ...
    );

    app_data.processed_image = processed_img;

    is_image_valid = ~isempty(app_data.processed_image);
    if strfind(result_status, 'ERROR')
        set(app_data.h_result_text, 'string', result_status, 'BackgroundColor', [1 0.7 0.7]);
        is_image_valid = false;
    elseif is_image_valid
        set(app_data.h_result_text, 'string', 'Processing Complete (Preview Mode)', 'BackgroundColor', [0.7 1 0.7]);
        disp(['[GUI DEBUG] Processed image successfully loaded into GUI. Size: ' mat2str(size(app_data.processed_image))]);
    else
        err_msg = 'WARNING: Processing complete, but image data is empty. Check run_malnutrition_detector.m and Python save path.';
        disp(['[GUI WARNING] ' err_msg]);
        set(app_data.h_result_text, 'string', err_msg, 'BackgroundColor', [1.0 0.9 0.5]);
    end

    if is_image_valid
        cla(app_data.h_axes_processed, 'reset');
        set(app_data.h_axes_processed, 'Units', 'normalized', 'Position', [0.67, 0.07, 0.30, 0.85]);
        set(app_data.h_axes_processed, 'visible', 'on');
        axes(app_data.h_axes_processed);
        imshow(app_data.processed_image);
        title('Processed Image Preview');
        colormap(app_data.h_axes_processed, 'default');
        axis off;
    else
        cla(app_data.h_axes_processed, 'reset');
        axes(app_data.h_axes_processed);
        title('Processed Image Preview (Failed to Load)');
        axis off;
        set(app_data.h_axes_processed, 'visible', 'on');
    end

    drawnow;
end

function run_prediction_callback(~, ~)
    global app_data;
    if isempty(app_data.current_image)
        set(app_data.h_result_text, 'string', 'ERROR: Load an image first!', 'BackgroundColor', [1 0.7 0.7]);
        return;
    end
    if isempty(app_data.op_list)
        set(app_data.h_result_text, 'string', 'ERROR: Add operations first!', 'BackgroundColor', [1 0.7 0.7]);
        return;
    end

    set(app_data.h_result_text, 'string', 'Running Prediction (ML/DL)...', 'BackgroundColor', [1 1 0.7]);
    drawnow;

    output_path = 'processed_output.png';

    [prediction_result, final_img] = run_malnutrition_detector( ...
        app_data.image_path, ...
        output_path, ...
        app_data.python_exec, ...
        app_data.python_script, ...
        app_data.op_list, ...
        'PREDICT' ...
    );

    app_data.processed_image = final_img;

    if strfind(prediction_result, 'ERROR')
        set(app_data.h_result_text, 'string', prediction_result, 'BackgroundColor', [1 0.7 0.7]);
    else
        set(app_data.h_result_text, 'string', ['PREDICTION: ' prediction_result], 'BackgroundColor', [0.7 1 0.7]);
        if ~isempty(app_data.processed_image)
            plot_image(app_data.h_axes_processed, app_data.processed_image, 'Prediction Input (224x224)');
        end
    end
end

