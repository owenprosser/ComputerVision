close all; clear; clc;

image = imread("ImgPIA.jpg");
original_image = image;
SE = strel('disk', 3);
image = rgb2gray(image);
image = imbinarize(image, 0.4);

asteroid_mask = bwareafilt(image, 1);
asteroid_mask = imclose(asteroid_mask, SE);
asteroid_mask = imfill(asteroid_mask, 'holes');
planet_mask = logical(image-asteroid_mask);
planet_mask = bwareafilt(planet_mask, 1);
planet_mask = imfill(planet_mask, 'holes');

asteroid = bsxfun(@times, original_image, cast(asteroid_mask, 'like', original_image));
planet = bsxfun(@times, original_image, cast(planet_mask, 'like', original_image));

asteroid = rgb2gray(asteroid);
planet = rgb2gray(planet);
figure;
imshow(original_image);
figure;
imshow(asteroid);
figure;
imshow(planet);

binaryImage = imbinarize(asteroid);
[r, c] = find(binaryImage == 1);
asteroid_coordinates = [round(mean(r)), round(mean(c))];
binaryImage = imbinarize(planet);
[r, c] = find(binaryImage == 1);
planet_coordinates = [round(mean(r)), round(mean(c))];

image_size = 100;
asteroid_crop = [asteroid_coordinates(1)-image_size asteroid_coordinates(2)+image_size/2 image_size image_size];
asteroid_texture = imcrop(asteroid,asteroid_crop);

planet_crop = [planet_coordinates(2) planet_coordinates(1)-20 image_size image_size];
planet_texture = imcrop(planet, planet_crop);
figure;
imshow(planet_texture);
figure;
imshow(asteroid_texture);

planet_texture_1 = imcrop(planet_texture, [50, 50, 49, 49]);
planet_texture_2 = imcrop(planet_texture, [50, 1, 49, 49]);

asteroid_texture_1 = imcrop(asteroid_texture, [1, 50, 49, 49]);
asteroid_texture_2 = imcrop(asteroid_texture, [50, 50, 49, 49]);

images_array = {planet_texture_1, planet_texture_2, asteroid_texture_1, asteroid_texture_2};

results = zeros(3,4);
last_image = zeros(50);

for i=1:4
    Im = images_array{i};
    for j=1:3
        radi = j*5;
        imageSize = size(Im);
        disp(imageSize);
        ci = [25, 25, radi];     % center and radius of circle ([c_row, c_col, r])
        [xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2));
        mask = uint8((xx.^2 + yy.^2)<ci(3)^2);
        croppedImage = uint8(zeros(size(Im)));
        croppedImage(:,:,1) = Im(:,:,1).*mask;               
        results(j, i) = sum(croppedImage(:)) - sum(last_image(:));

        last_image = croppedImage;
    end
    last_image = zeros(50);
end

% for i=1:4
%     for j=1:3
%         results(j,i) = j;
%     end
% end

% % Prepare image
% f = planet_texture;
% imshow(f);
% % Compute Fourier Transform
% F = fft2(f,256,256);
% figure;
% imshow(F);
% F = fftshift(F); % Center FFT
% figure;
% imshow(F);

%x = input(" ");