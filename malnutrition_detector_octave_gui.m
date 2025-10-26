% This is the main function for the Malnutrition Detector GUI,
% designed to use basic Octave/MATLAB graphics functions with fixed positioning.

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
                'canny_edge_detection','laplacian_sharpening','color_segmentation','cropping', 'resizing'};
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
% --- Scrollbar Callback Function ---
% ----------------------------------------------------------------------
function slider_callback(src, ~, panelHandle, H)
    % H: inner panel height (2.0)
    v = get(src, 'Value');

    % Total scroll range = H - 1 (1.0 in this case).
    newY = v * (1 - H);

    set(panelHandle, 'Position', [0, newY, 0.95, H]);
end

% ----------------------------------------------------------------------
% --- Helper Functions ---
% ----------------------------------------------------------------------

function update_op_listbox()
    % Updates the string content of the operations listbox based on app_data.op_list
    global app_data;
    op_display = {};
    for i = 1:length(app_data.op_list)
        op = app_data.op_list{i};
        op_name = op{1};
        op_args = op(2:end);
        arg_str = '';
        for j = 1:length(op_args)
            current_arg = op_args{j};
            % Format arguments for display
            if iscell(current_arg) % Handle nested cells like for color segmentation
                nested_str = ['{' sprintf('%.2f,', cell2mat(current_arg))];
                arg_str = [arg_str ' | ' nested_str(1:end-1) '}']; % Remove trailing comma
            elseif isnumeric(current_arg)
                if current_arg == round(current_arg)
                    arg_str = [arg_str ' | ' sprintf('%d', current_arg)];
                else
                    arg_str = [arg_str ' | ' sprintf('%.2f', current_arg)];
                end
            elseif ischar(current_arg) % Added check for string args (e.g., interpolation method)
                arg_str = [arg_str ' | ' current_arg];
            end
        end
        op_display{i} = [num2str(i) ': ' op_name arg_str];
    end
    % Update the listbox content
    set(app_data.h_op_listbox, 'string', op_display);
    % Adjust selection if list is empty
    if isempty(op_display)
        set(app_data.h_op_listbox, 'value', 0);
    end
end

function plot_image(h_axes, img, title_str)
    % Displays an image in the specified axes handle
    axes(h_axes); % Make the target axes current
    if isempty(img)
        cla; % Clear axes if image is empty
        title(title_str);
        axis off;
    else
        imshow(img); % Display the image
        title(title_str);
        axis off; % Turn off axis ticks/labels
    end
    drawnow; % Ensure the plot updates immediately
end

% --- DYNAMIC INPUT HELPER ---

function update_parameter_inputs(params_to_show, default_values)
    % Shows/hides parameter input fields based on the selected operation
    global app_data;
    % Hide all parameter controls first
    for i = 1:4
        % Defensive check: Ensure the handle exists before trying to set properties
        if isfield(app_data, ['h_param_label_' num2str(i)]) && ishandle(app_data.(['h_param_label_' num2str(i)]))
            set(app_data.(['h_param_label_' num2str(i)]), 'visible', 'off');
        end
         if isfield(app_data, ['h_param_input_' num2str(i)]) && ishandle(app_data.(['h_param_input_' num2str(i)]))
            set(app_data.(['h_param_input_' num2str(i)]), 'visible', 'off', 'string', '');
        end
    end
    % Show and configure the required controls
    num_params = length(params_to_show);
    for i = 1:num_params
        % Ensure handles exist before setting properties
         if isfield(app_data, ['h_param_label_' num2str(i)]) && ishandle(app_data.(['h_param_label_' num2str(i)]))
            set(app_data.(['h_param_label_' num2str(i)]), 'string', [params_to_show{i} ':'], 'visible', 'on');
         end
         if isfield(app_data, ['h_param_input_' num2str(i)]) && ishandle(app_data.(['h_param_input_' num2str(i)]))
            set(app_data.(['h_param_input_' num2str(i)]), 'string', default_values{i}, 'visible', 'on');
         end
    end
     % Using drawnow expose here might be more reliable for visibility updates
     drawnow expose;
end

% ----------------------------------------------------------------------
% --- Callback Functions ---
% ----------------------------------------------------------------------

function op_menu_callback(~, ~)
    % Called when the user changes the selection in the operation dropdown menu
    global app_data;
    op_names = get(app_data.h_op_menu, 'string');
    selected_index = get(app_data.h_op_menu, 'value');
    selected_op_name = op_names{selected_index};

    % Update the visibility and labels of parameter input fields
    switch selected_op_name
        case 'brightness_contrast'
            update_parameter_inputs({'Brightness (Int)', 'Contrast (Float)'}, {'50', '1.5'});
        case 'rotation'
            update_parameter_inputs({'Angle (Degrees)'}, {'45'});
        case {'dilation', 'erosion', 'mean_filter', 'median_filter'}
            update_parameter_inputs({'Kernel Size (Int)'}, {'5'});
        case 'canny_edge_detection'
            update_parameter_inputs({'Low Threshold (0-1)', 'High Threshold (0-1)'}, {'0.1', '0.5'});
        case 'cropping'
            update_parameter_inputs({'Start X (px)', 'Start Y (px)', 'Width (px)', 'Height (px)'}, {'100', '100', '200', '200'});
        case 'color_segmentation'
            update_parameter_inputs({'Hue Min (0-1)', 'Hue Max (0-1)', 'Sat Min (0-1)', 'Sat Max (0-1)'}, {'0.0', '0.3', '0.2', '0.8'});
        case 'resizing' % *** ADDED RESIZING CASE ***
            update_parameter_inputs({'New Width (px)', 'New Height (px)'}, {'224', '224'});
        case {'otsu_thresholding', 'hist_equalization', 'laplacian_sharpening'}
            update_parameter_inputs({}, {}); % No parameters needed
        otherwise
            update_parameter_inputs({}, {});
    end
    set(app_data.h_result_text, 'string', ['Ready to add: ' selected_op_name], 'BackgroundColor', [1 1 1]);
    % Moved drawnow expose to update_parameter_inputs
end

function load_image_callback(~, ~)
    % Called when the "Load Image" button is pressed
    global app_data;
    [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'}, 'Select an Image File');
    if filename ~= 0 % Check if a file was selected
        app_data.image_path = fullfile(pathname, filename);
        try
            app_data.current_image = imread(app_data.image_path);
            set(app_data.h_result_text, 'string', ['Image Loaded: ' filename], 'BackgroundColor', [0.7 1 0.7]);
            plot_image(app_data.h_axes_original, app_data.current_image, 'Original Image');
            plot_image(app_data.h_axes_processed, [], 'Processed Image'); % Clear processed display
        catch ME
            set(app_data.h_result_text, 'string', ['Error loading image: ' ME.message], 'BackgroundColor', [1 0.7 0.7]);
            app_data.current_image = [];
            plot_image(app_data.h_axes_original, [], 'Original Image'); % Clear original display on error
        end
    else
        set(app_data.h_result_text, 'string', 'Image loading cancelled.', 'BackgroundColor', [1 1 0.7]);
    end
end

function add_operation_callback(~, ~)
    % Called when the "Add" button is pressed
    global app_data;
    op_names = get(app_data.h_op_menu, 'string');
    selected_index = get(app_data.h_op_menu, 'value');
    selected_op_name = op_names{selected_index};
    op_info = {};
    op_params = {};
    is_valid = true;
    error_msg = '';

    % Helper to read and validate numeric input from GUI fields
    function [val, is_present] = read_param(index)
        input_handle = app_data.(['h_param_input_' num2str(index)]);
        is_present = strcmp(get(input_handle, 'visible'), 'on');
        val = NaN; % Default to invalid
        if is_present
            str_val = get(input_handle, 'string');
            num_val = str2double(str_val); % Use str2double for better handling
            if ~isempty(str_val) && isscalar(num_val) && ~isnan(num_val)
                val = num_val;
            end
        end
    end

    % --- DYNAMIC PARAMETER READING AND VALIDATION ---
    try
        switch selected_op_name
            case 'brightness_contrast'
                [brightness, ~] = read_param(1);
                [contrast, ~] = read_param(2);
                if isnan(brightness) || isnan(contrast)
                    is_valid = false; error_msg = 'ERROR: Brightness and Contrast must be valid numbers.';
                else
                    op_params = {brightness, contrast};
                end
            case 'rotation'
                [angle, is_present] = read_param(1);
                if isnan(angle) || ~is_present
                    is_valid = false; error_msg = 'ERROR: Rotation Angle must be a valid number.';
                else
                    op_params = {angle};
                end
            case {'dilation', 'erosion', 'mean_filter', 'median_filter'}
                [kernel, is_present] = read_param(1);
                if isnan(kernel) || ~is_present || kernel <= 0 || kernel ~= round(kernel)
                    is_valid = false; error_msg = 'ERROR: Kernel Size must be a positive integer.';
                else
                    op_params = {kernel};
                end
            case 'canny_edge_detection'
                [low_thresh, ~] = read_param(1);
                [high_thresh, ~] = read_param(2);
                if isnan(low_thresh) || isnan(high_thresh) || high_thresh <= low_thresh || low_thresh < 0 || high_thresh > 1
                    is_valid = false; error_msg = 'ERROR: Canny thresholds invalid (0-1, High > Low).';
                else
                    op_params = {low_thresh, high_thresh};
                end
            case 'cropping'
                [x, ~] = read_param(1); [y, ~] = read_param(2);
                [w, ~] = read_param(3); [h, ~] = read_param(4);
                if isnan(x) || isnan(y) || isnan(w) || isnan(h) || w <= 0 || h <= 0 || x<1 || y<1
                    is_valid = false; error_msg = 'ERROR: Cropping parameters invalid (X,Y>=1, W,H>0).';
                else
                    op_params = {round(x), round(y), round(w), round(h)}; % Ensure integers
                end
            case 'color_segmentation'
                [h_min, ~] = read_param(1); [h_max, ~] = read_param(2);
                [s_min, ~] = read_param(3); [s_max, ~] = read_param(4);
                if isnan(h_min) || isnan(h_max) || isnan(s_min) || isnan(s_max) || h_max < h_min || s_max < s_min || ...
                   h_min<0 || h_max>1 || s_min<0 || s_max>1
                    is_valid = false; error_msg = 'ERROR: Color parameters invalid (0.0-1.0, Max >= Min).';
                else
                    op_params = {{h_min, h_max, s_min, s_max}}; % Pass as nested cell
                end
            case 'resizing' % *** ADDED RESIZING PARAMETER READING ***
                [new_w, ~] = read_param(1);
                [new_h, ~] = read_param(2);
                if isnan(new_w) || isnan(new_h) || new_w <= 0 || new_h <= 0 || new_w~=round(new_w) || new_h~=round(new_h)
                    is_valid = false; error_msg = 'ERROR: Width and Height must be positive integers.';
                else
                    % Params for apply_resizing: image, new_rows(H), new_cols(W), method
                    op_params = {new_h, new_w, 'bilinear'}; % Add default method
                end
            case {'otsu_thresholding', 'hist_equalization', 'laplacian_sharpening'}
                op_params = {}; % No parameters
            otherwise
                op_params = {};
        end
    catch ME
        is_valid = false;
        error_msg = ['ERROR reading parameters: ' ME.message];
    end

    % Add the operation to the list if valid
    if is_valid
        op_info = {selected_op_name, op_params{:}}; % Unpack parameters correctly
        app_data.op_list{end+1} = op_info;
        update_op_listbox();
        set(app_data.h_op_listbox, 'value', length(app_data.op_list)); % Select the newly added item
        set(app_data.h_result_text, 'string', ['Added operation: ' selected_op_name], 'BackgroundColor', [0.7 1 0.7]);
    else
        set(app_data.h_result_text, 'string', error_msg, 'BackgroundColor', [1 0.7 0.7]); % Show validation error
    end
end

function remove_operation_callback(~, ~)
    % Called when the "Remove Selected Operation" button is pressed
    global app_data;
    selected_item_index = get(app_data.h_op_listbox, 'value');

    if isempty(app_data.op_list) || selected_item_index == 0
        set(app_data.h_result_text, 'string', 'No operation selected to remove.', 'BackgroundColor', [1 1 0.7]);
        return;
    end

    if selected_item_index <= length(app_data.op_list)
        app_data.op_list(selected_item_index) = []; % Remove the item

        % Adjust listbox selection
        new_selection = selected_item_index;
        if new_selection > length(app_data.op_list) && ~isempty(app_data.op_list)
            new_selection = length(app_data.op_list); % Select last item if last was removed
        elseif isempty(app_data.op_list)
            new_selection = 0; % No selection if list becomes empty
        end
        set(app_data.h_op_listbox, 'value', new_selection);

        update_op_listbox(); % Refresh the listbox display
        set(app_data.h_result_text, 'string', 'Removed selected operation.', 'BackgroundColor', [1 1 1]);
    else
         set(app_data.h_result_text, 'string', 'Invalid selection to remove.', 'BackgroundColor', [1 1 0.7]);
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




