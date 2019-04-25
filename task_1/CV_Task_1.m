clear; close all; clc;

currentPath = mfilename('fullpath');
currentPath = erase(currentPath, 'CV_Task_1');
image1Path = strcat(currentPath, 'skin_Lesion_Dataset/ISIC_0000416.jpg');
image2Path = strcat(currentPath, 'skin_Lesion_Dataset/ISIC_0011210.jpg');
image3Path = strcat(currentPath, 'skin_Lesion_Dataset/ISIC_0011357.jpg');

ground1Path = strcat(currentPath, 'skin_Lesion_Dataset/ISIC_0000416_Segmentation.png');
ground2Path = strcat(currentPath, 'skin_Lesion_Dataset/ISIC_0011210_Segmentation.png');
ground3Path = strcat(currentPath, 'skin_Lesion_Dataset/ISIC_0011357_Segmentation.png');

image1 = imread(image1Path);
image2 = imread(image2Path);
image3 = imread(image3Path);

ground1 = imread(ground1Path);
ground2 = imread(ground2Path);
ground3 = imread(ground3Path);

imagesArray = {image1, image2, image3};
groundTruthArray = {ground1, ground2, ground3};

SE = strel('disk', 3);

count = 1;

for i = 1:size(imagesArray, 2)
    currentImage = imagesArray{i};
    
    currentImage = currentImage(:,:,3);
    currentImage = imbinarize(currentImage, 0.5);
    
    currentImage = ~currentImage;
    
    currentImage = imerode(currentImage, SE);

    currentImage = bwareafilt(currentImage, 1);
    
    currentImage = imfill(currentImage, 'holes');
    
    currentImageDouble = im2double(currentImage);
    currentGround = im2double(groundTruthArray{i});
    diceScore = dice(currentImageDouble, currentGround);
    disp(diceScore);
    
    subplot(3, 3, count);
    sgtitle('Simple Segmentation')
    imshow(currentImage);
    title("Segmented: " + diceScore);
    count = count + 1;
    
    subplot(3, 3, count);
    imshow(imagesArray{i});
    title("Original");
    count = count + 1;
    
    subplot(3, 3, count);
    imshow(groundTruthArray{i});
     title("Ground Truth");
    count = count + 1;
end

i = 3;
currentImage = imagesArray{i};
currentImage = rgb2gray(currentImage);
se = strel('disk',3);
currentImage = imsubtract(imadd(currentImage,imbothat(currentImage,se)),imtophat(currentImage,se));
[L,Centers] = imsegkmeans(currentImage,3);
currentImage = labeloverlay(currentImage,L);
figure;
imshow(currentImage);
figure;

lab_he = rgb2lab(imagesArray{i});
ab = lab_he(:,:,2:3);
ab = im2single(ab);
nColors = 3;
% repeat the clustering 3 times to avoid local minima
pixel_labels = imsegkmeans(ab,nColors,'NumAttempts',3);
imshow(pixel_labels,[])
title('Image Labeled by Cluster Index');
mask1 = pixel_labels==1;
cluster1 = imagesArray{i} .* uint8(mask1);
imshow(cluster1)
title('Objects in Cluster 1');

mask2 = pixel_labels==2;
cluster2 = imagesArray{i} .* uint8(mask2);
figure;
imshow(cluster2)
title('Objects in Cluster 2');

mask3 = pixel_labels==3;
cluster3 = imagesArray{i} .* uint8(mask3);
figure;
imshow(cluster3)
title('Objects in Cluster 3');