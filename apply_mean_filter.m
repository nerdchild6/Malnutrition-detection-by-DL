function filtered_image = apply_mean_filter(image, filter_size)
  % This function applies a Mean (Averaging) Filter to the image.
  % It reduces noise (like Gaussian noise) but can blur edges.
  % image: Input image.
  % filter_size: Size of the filter kernel (e.g., 3).

  % MANDATORY: Load the image package as it contains 'imbinarize'
  pkg load image;

  % Ensure the image is in double format for accurate convolution
  img_double = im2double(image);

  % Create a square averaging kernel (e.g., 3x3 or 5x5)
  % The kernel elements sum to 1 to maintain brightness
  h = ones(filter_size, filter_size) / (filter_size * filter_size);

  % Apply the 2D spatial filter (convolution)
  % We use 'imfilter' or 'conv2' here. We'll use filter2 for simplicity
  % and compatibility, and apply it channel-wise for color images.

  if size(image, 3) == 3
      % Process each channel (R, G, B) independently
      filtered_image_double = zeros(size(img_double));
      for i = 1:3
          filtered_image_double(:,:,i) = filter2(h, img_double(:,:,i), 'same');
      end
  else
      % Grayscale image
      filtered_image_double = filter2(h, img_double, 'same');
  end

  % Convert back to uint8
  filtered_image = im2uint8(filtered_image_double);

end
