function filtered_image = apply_median_filter(image, filter_size)
  % This function applies a Median Filter to the image channel-wise.
  % Median filtering is excellent for removing 'salt-and-pepper' noise
  % while preserving edges better than mean filtering.
  %
  % Parameters:
  %   image: Input image (uint8 or other class).
  %   filter_size: Size of the filter kernel (e.g., [3 3]). Defaults to [3 3].
  %
  % Returns:
  %   filtered_image: The processed, denoised image.

  % Ensure the image package is loaded
  pkg load image;

  % Default filter size if not provided
  if nargin < 2
      filter_size = [3 3];
  endif

  % Initialize the output image with the same size and class as the input
  filtered_image = zeros(size(image), class(image));

  % Check if the image is a color image (3 channels)
  if size(image, 3) == 3
      % Process each channel (R, G, B) independently
      for i = 1:3
          % Apply medfilt2 to the current channel (which is 2D)
          % medfilt2 handles boundary conditions implicitly.
          filtered_image(:,:,i) = medfilt2(image(:,:,i), filter_size);
      end
  else
      % Grayscale image (2D) - apply medfilt2 directly
      filtered_image = medfilt2(image, filter_size);
  end

endfunction

