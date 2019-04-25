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

asteroid_texture = bsxfun(@times, original_image, cast(asteroid_mask, 'like', original_image));
planet_texture = bsxfun(@times, original_image, cast(planet_mask, 'like', original_image));

figure;
imshow(original_image);
figure;
imshow(asteroid_texture);
figure;
imshow(planet_texture);

