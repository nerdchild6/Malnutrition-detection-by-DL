function rotated_image = apply_rotation(image, angle_degrees)
  % This function rotates the image by a specified angle in degrees.
  % It uses 'bilinear' interpolation for smoothness.
  % The output image size may expand to contain the entire rotated content,
  % with empty areas typically filled with black (0).
  %
  % Parameters:
  %   image: Input image (uint8 or other class).
  %   angle_degrees: Angle of rotation in degrees (e.g., 45, -90).
  %
  % Returns:
  %   rotated_image: The transformed image (uint8).

  % Ensure the image package is loaded
  pkg load image;

  % Ensure the image is in uint8 format for consistency
  img_uint8 = im2uint8(image);

  % Use 'bilinear' interpolation. Octave/MATLAB automatically sets 'crop' to 'off'
  % and fills empty space with black (0) when called this way.
  rotated_image = imrotate(img_uint8, angle_degrees, 'bilinear');

endfunction

