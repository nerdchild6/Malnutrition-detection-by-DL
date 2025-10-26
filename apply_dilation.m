function dilated_image = apply_dilation(image, kernel_size)
% APPLY_DILATION performs morphological dilation on an image.
%   This version is compatible with Octave and uses imdilate.
%
%   Args:
%       image (matrix): The input image (expected to be grayscale or binary).
%       kernel_size (int): The size of the structuring element (e.g., 3, 5).
%
%   Returns:
%       dilated_image (matrix): The result of the dilation operation.

    % Ensure image is grayscale (if it was a color image initially)
    if size(image, 3) > 1
        % Convert to grayscale using a standard Octave/MATLAB function
        image_gray = rgb2gray(image);
    else
        image_gray = image;
    end

    % --- Octave Compatibility Fix: Replace imbinarize ---
    % Imdilate requires a binary (logical) image. Since imbinarize is undefined,
    % we enforce binarization by thresholding the grayscale image.

    % Find the threshold using Otsu's method (imbinarize default behavior is often Otsu)
    T = graythresh(image_gray);

    % Apply the threshold to convert to a logical (binary) image
    binary_image = im2bw(image_gray, T);

    % Define the structuring element (a square)
    se = strel('square', kernel_size);

    % Perform dilation
    dilated_image = imdilate(binary_image, se);
end

