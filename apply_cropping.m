function cropped_image = apply_cropping(image, x_start, y_start, width, height)
  % This function crops a rectangular region from the image.
  %
  % Parameters:
  %   image: Input image (uint8 or other class).
  %   x_start: Starting column index (from the left, 1-based).
  %   y_start: Starting row index (from the top, 1-based).
  %   width: Width of the region to crop.
  %   height: Height of the region to crop.
  %
  % Returns:
  %   cropped_image: The transformed image (uint8).

  % Ensure the image package is loaded
  pkg load image;

  % Ensure the image is in uint8 format for consistency
  img_uint8 = im2uint8(image);

  % The cropping rectangle is defined by [x_start, y_start, width, height].
  rect = [x_start, y_start, width, height];

  % Use Octave's 'imcrop' function.
  cropped_image = imcrop(img_uint8, rect);

endfunction

