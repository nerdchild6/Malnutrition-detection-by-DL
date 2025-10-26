function edge_image = apply_canny_edge_detection(image, sigma, lower_threshold, upper_threshold)
  % This function applies the Canny edge detection algorithm.
  % Canny is widely used for reliable and thin edge mapping.
  %
  % Parameters:
  %   image: Input image.
  %   sigma: Standard deviation of the Gaussian filter (smoothness). Defaults to 1.0.
  %   lower_threshold: Low threshold for hysteresis (normalized to [0, 1]). Defaults to 0.1.
  %   upper_threshold: High threshold for hysteresis (normalized to [0, 1]). Defaults to 0.5.
  %
  % Returns:
  %   edge_image: A binary image (uint8) where edges are white.

  % Ensure the image package is loaded
  pkg load image;

  % Set default parameters if not provided
  if nargin < 4
    upper_threshold = 0.5;
  endif
  if nargin < 3
    lower_threshold = 0.1;
  endif
  if nargin < 2
    sigma = 1.0;
  endif

  % Canny edge detection works best on grayscale images.
  if size(image, 3) == 3
      % Convert color image to grayscale
      gray_image = rgb2gray(image);
  else
      gray_image = image;
  end

  % Ensure grayscale image is double for accurate threshold application
  gray_double = im2double(gray_image);

  % Use the built-in Octave 'edge' function with the 'Canny' method.
  % The output (binary_edge) is a logical array.
  binary_edge = edge(gray_double, 'canny', [lower_threshold, upper_threshold], sigma);

  % Convert the logical output (0s and 1s) to uint8 (0 and 255) for visualization
  edge_image = im2uint8(binary_edge);

endfunction

