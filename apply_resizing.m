function resized_image = apply_resizing(image, new_rows, new_cols, interpolation_method)
  % This function resizes (scales) the image to a specified dimension.
  % It uses interpolation for better quality resizing.
  % This function is critical for resizing the final image to 224x224 before ML prediction.
  %
  % Parameters:
  %   image: Input image.
  %   new_rows: Desired number of rows (height).
  %   new_cols: Desired number of columns (width).
  %   interpolation_method: Method for interpolation (e.g., 'nearest', 'bilinear', 'bicubic').
  %
  % Returns:
  %   resized_image: The transformed image (uint8).

  % Ensure the image package is loaded
  pkg load image;

  % Set default interpolation method if not provided
  if nargin < 4
    interpolation_method = 'bilinear';
  endif

  % Ensure the image is in uint8 format before resizing
  img_uint8 = im2uint8(image);

  % Use Octave's 'imresize' function.
  % imresize works on uint8 directly.
  resized_image = imresize(img_uint8, [new_rows, new_cols], interpolation_method);

endfunction

