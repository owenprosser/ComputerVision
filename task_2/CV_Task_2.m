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

F = fft2(planet_texture);
S = abs(F);
%get the centered spectrum
Fsh = fftshift(F);
%apply log transform
S2 = log(1+abs(Fsh));
figure;imshow(S2,[]);title('log transformed - Planet')

F = fft2(asteroid_texture);
S = abs(F);
%get the centered spectrum
Fsh = fftshift(F);
%apply log transform
S2 = log(1+abs(Fsh));
figure;imshow(S2,[]);title('log transformed - Asteroid')
disp('hello')