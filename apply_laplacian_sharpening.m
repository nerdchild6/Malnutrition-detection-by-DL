function sharpened_image = apply_laplacian_sharpening(image)
  % This function applies a Laplacian kernel for image sharpening.
  % Sharpening enhances fine details and edges.
  % image: Input image.

  % MANDATORY: Load the image package as it contains 'imbinarize'
  pkg load image;

  % Ensure the image is in double format for calculations
  img_double = im2double(image);

  % Define the Laplacian kernel (a common 3x3 mask)
  % This kernel highlights sudden changes (edges).
  laplacian_kernel = [0 1 0; 1 -4 1; 0 1 0];

  % Process the image channel by channel
  if size(image, 3) == 3
      laplacian_output = zeros(size(img_double));
      for i = 1:3
          % Apply the convolution
          laplacian_output(:,:,i) = filter2(laplacian_kernel, img_double(:,:,i), 'same');
      end
  else
      % Grayscale image
      laplacian_output = filter2(laplacian_kernel, img_double, 'same');
  end

  % Sharpening step: sharpened = original - laplacian_output
  % Subtracting the Laplacian output restores the background while emphasizing edges.
  sharpened_image_double = img_double - laplacian_output;

  % Clip pixel values and convert back to uint8
  sharpened_image_double(sharpened_image_double < 0) = 0;
  sharpened_image_double(sharpened_image_double > 1) = 1;
  sharpened_image = im2uint8(sharpened_image_double);

end
