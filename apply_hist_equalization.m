function equalized_image = apply_hist_equalization(image)
  % This function enhances image contrast using Histogram Equalization.
  % It handles both color (RGB) and grayscale images.
  %
  % Parameters:
  %   image: Input image (uint8 or double)
  %
  % Returns:
  %   equalized_image: Output image (uint8) with enhanced contrast

  % Ensure the image package is loaded for histeq, rgb2hsv, etc.
  pkg load image;

  % Convert image to standard uint8 if it's not already, to ensure
  % histeq works with 256 levels, though it handles double fine.
  original_class = class(image);
  image_uint8 = im2uint8(image);

  % Check if the image is a color image (has 3 dimensions).
  if size(image_uint8, 3) == 3
    % If it is a color image, convert it to the HSV color space.
    hsv_image = rgb2hsv(image_uint8);

    % Apply Histogram Equalization only to the V (Value/Brightness) channel
    % to preserve the original Hue and Saturation.
    hsv_image(:, :, 3) = histeq(hsv_image(:, :, 3));

    % Convert the image back to the RGB color space.
    equalized_image = hsv2rgb(hsv_image);

    % Convert back to uint8 for consistency (hsv2rgb might output double)
    equalized_image = im2uint8(equalized_image);
  else
    % If it is a grayscale image, apply histeq directly.
    equalized_image = histeq(image_uint8);
  end

endfunction

