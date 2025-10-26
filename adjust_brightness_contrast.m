function adjusted_image = adjust_brightness_contrast(image, brightness, contrast)
  % This function adjusts the brightness and contrast of an input image.
  %
  % Parameters:
  %   image: Input image (uint8 or other class).
  %   brightness: Value to shift brightness (e.g., -255 to 255).
  %   contrast: Multiplier factor for contrast (e.g., 0.5 to 2.0).
  %
  % Returns:
  %   adjusted_image: The processed image (uint8)

  % Ensure the image package is loaded
  pkg load image;

  % Convert the image data type to double for accurate calculations in the range [0, 1].
  img_double = im2double(image);

  % Normalize the brightness value from [-255, 255] to the [-1, 1] range
  % for image processing (where image data is [0, 1]).
  brightness_normalized = brightness / 255.0;

  % Apply the linear transformation formula: new_pixel = contrast * old_pixel + normalized_brightness
  % The 'contrast' is the slope and 'normalized_brightness' is the intercept.
  adjusted_image_double = contrast * img_double + brightness_normalized;

  % Clip pixel values to the valid range [0, 1] (handle underflow and overflow).
  % Values less than 0 become 0, and values greater than 1 become 1.
  adjusted_image_double(adjusted_image_double < 0) = 0;
  adjusted_image_double(adjusted_image_double > 1) = 1;

  % Convert the image back to the original data type (uint8).
  adjusted_image = im2uint8(adjusted_image_double);

endfunction

