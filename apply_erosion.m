function eroded_image = apply_erosion(image, kernel_size)
% APPLY_EROSION performs morphological erosion on an image.
%   This version is compatible with Octave and uses imerode.
%
%   Args:
%       image (matrix): The input image (expected to be grayscale or binary).
%       kernel_size (int): The size of the structuring element (e.g., 3, 5).
%
%   Returns:
%       eroded_image (matrix): The result of the erosion operation.

    % --- FIX: Ensure image is numeric (double) for compatibility with graythresh ---
    % If the image is logical (from a previous binarization step),
    % graythresh will fail unless it's converted to a numeric type.
    if islogical(image)
        image = double(image);
    end

    % Ensure image is grayscale (if it was a color image initially)
    if size(image, 3) > 1
        % Convert to grayscale using a standard Octave/MATLAB function
        image_gray = rgb2gray(image);
    else
        image_gray = image;
    end

    % --- Octave Compatibility Fix: Replace imbinarize ---
    % Imerode requires a binary (logical) image. Since imbinarize is undefined,
    % we enforce binarization by thresholding the grayscale image using Otsu's method.

    % Find the threshold using Otsu's method (standard for binarization)
    T = graythresh(image_gray);

    % Apply the threshold to convert to a logical (binary) image
    binary_image = im2bw(image_gray, T);

    % Define the structuring element (a square)
    se = strel('square', kernel_size);

    % Perform erosion
    eroded_image = imerode(binary_image, se);
end

