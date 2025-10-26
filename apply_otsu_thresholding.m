function binary_image = apply_otsu_thresholding(image)
  % This function segments the image using Otsu's method for automatic thresholding.
  % It returns a binary image (segmented foreground).
  % image: Input image.

  % Load the image package to ensure necessary functions are available.
  pkg load image;

  % Otsu's method works on grayscale images.
  if size(image, 3) == 3
      % Convert to grayscale
      gray_image = rgb2gray(image);
  else
      gray_image = image;
  end

  % Get the optimal threshold value using graythresh (Octave/MATLAB function)
  % The threshold (T) is normalized between 0 and 1.
  T = graythresh(gray_image);

  % Apply the threshold to create a binary image.
  % NOTE: Using 'im2bw' instead of 'imbinarize' for better compatibility with
  % older Octave Image package versions.
  binary_image = im2bw(gray_image, T);

  % Ensure output is uint8 (0 or 255) for consistent display in the GUI
  % im2bw returns a logical array, so we convert it to uint8.
  binary_image = im2uint8(binary_image);

endfunction

