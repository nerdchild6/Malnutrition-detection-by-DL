function segmented_image = apply_color_segmentation(image, op_args)
% APPLY_COLOR_SEGMENTATION performs segmentation based on HSV color ranges.
% This version is fixed to unpack the parameters correctly from op_args.
%
% Args:
%     image (matrix): The input RGB image.
%     op_args (cell array): A cell array containing the segmentation parameters.
%                           Expected format: {hue_min, hue_max, sat_min, sat_max}
%
% Returns:
%     segmented_image (matrix): The resulting segmented binary image.

    % Load the image package
    pkg load image;

    % --- FIX: UNPACK ARGUMENTS ---
    % op_args is a cell array like {{0.1, 0.3, 0.2, 0.8}}.
    % We need to extract the numeric values from the nested cell structure.

    % Check if op_args contains the parameters directly (preferred method)
    if iscell(op_args) && length(op_args) == 4
        [hue_min, hue_max, sat_min, sat_max] = op_args{:};
    elseif iscell(op_args) && iscell(op_args{1}) && length(op_args{1}) == 4
        % If the parameters are passed as a single nested cell array (e.g., {{...}})
        params = op_args{1};
        [hue_min, hue_max, sat_min, sat_max] = params{:};
    else
        % Fallback or error case (adjust ranges to suit your default implementation if needed)
        error('apply_color_segmentation: Invalid number or format of input parameters.');
    end

    % Ensure image is RGB (3 channels) and convert to double for HSV conversion
    if size(image, 3) ~= 3
        error('Color segmentation requires an RGB image.');
    end

    % Convert image to HSV color space (values are typically 0.0 to 1.0)
    hsv_image = rgb2hsv(im2double(image));

    % Separate the H, S, V channels
    H = hsv_image(:, :, 1);
    S = hsv_image(:, :, 2);
    % V = hsv_image(:, :, 3); % Value channel often not used for simple color segmentation

    % Create a binary mask based on Hue and Saturation ranges
    % This logic performs AND operation on the two masks

    % Hue Mask: Check if Hue is within [hue_min, hue_max]
    hue_mask = (H >= hue_min) & (H <= hue_max);

    % Saturation Mask: Check if Saturation is within [sat_min, sat_max]
    sat_mask = (S >= sat_min) & (S <= sat_max);

    % Combine the masks
    segmented_mask = hue_mask & sat_mask;

    % Apply the mask to the original image (optional, but good for visualization)
    % For a binary output (as suggested by the previous error flow), return the mask.
    segmented_image = im2uint8(segmented_mask);
end
