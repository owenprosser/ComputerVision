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

SE = strel('disk', 2);

count = 1;
averageDICE = 0;
for i = 1:size(imagesArray, 2)
    currentImage = imagesArray{i};

    currentImage = currentImage(:,:,3);
    currentImage = ~imbinarize(currentImage, 0.5);
    currentImage = imerode(currentImage, SE);
    currentImage = bwareafilt(currentImage, 1);
    currentImage = imfill(currentImage, 'holes');

    currentImageDouble = im2double(currentImage);
    currentGround = im2double(groundTruthArray{i});
    diceScore = dice(currentImageDouble, currentGround);
    averageDICE = averageDICE + diceScore;
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
disp("Average DICE: "+averageDICE/3);
figure;
count = 1;
averageDICE = 0;
SE = strel('disk', 5);
for i = 1:size(imagesArray, 2)
    currentImage = imagesArray{i};
    currentImage = uint8((currentImage-min(currentImage(:)))/(max(currentImage(:))-min(currentImage(:)))*255);
    original = currentImage(:,:,3);
    bothatFiltered = imbothat(original,SE);
    mask = imbinarize(bothatFiltered, 0.07);
    mask = imdilate(mask, SE);
    image = original - bothatFiltered;
    image = regionfill(image, mask);

    nColors = 5;
    % repeat the clustering 3 times to avoid local minima
    pixel_labels = imsegkmeans(image,nColors,'NumAttempts',3);
    mask2 = pixel_labels==1;
    currentImage = image .* uint8(mask2);

    currentImage = imbinarize(currentImage);
    currentImage = ~currentImage;

    currentImage = imfill(currentImage, 'holes');
    currentImage = bwareafilt(currentImage, 1);
    currentImage = imdilate(currentImage, SE);

    currentImageDouble = im2double(currentImage);
    currentGround = im2double(groundTruthArray{i});
    diceScore = dice(currentImageDouble, currentGround);
    averageDICE = averageDICE + diceScore;
    disp(diceScore);

    subplot(3, 3, count);
    sgtitle('Bottom-hat filtering and K-means segmentation')
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
disp("Average DICE: "+averageDICE/3);
%figure; imshow(outputImage);
%x = input("exit");