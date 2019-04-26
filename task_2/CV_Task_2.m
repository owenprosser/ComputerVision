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

size = 100;
asteroid_crop = [asteroid_coordinates(1)-size asteroid_coordinates(2)+size/2 size size];
asteroid_texture = imcrop(asteroid,asteroid_crop);

planet_crop = [planet_coordinates(2) planet_coordinates(1)-20 size size];
planet_texture = imcrop(planet, planet_crop);
figure;
imshow(planet_texture);
figure;
imshow(asteroid_texture);

% Prepare image
f = planet_texture;
imshow(f);
% Compute Fourier Transform
F = fft2(f,256,256);
figure;
imshow(F);
F = fftshift(F); % Center FFT
figure;
imshow(F);
% Measure the minimum and maximum value of the transform amplitude
min(min(abs(F)));
max(max(abs(F)));
figure;
imshow(abs(F),[0 1000]); colormap(jet); colorbar
figure;
imshow(log(1+abs(F)),[0,10]); colormap(jet); colorbar
% Look at the phases
figure;
imshow(angle(F),[-pi,pi]); colormap(jet); colorbar

x = input(" ");