close all; clc;

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
    
    disp(groundIndex);
    
    subplot(3, 3, count);
    imshow(currentImage);
    title("Segmented");
    count = count + 1;
    
    subplot(3, 3, count);
    imshow(imagesArray{i});
    title("Original");
    count = count + 1;
    
    subplot(3, 3, count);
    imshow(groundTruthArray{i});
     title("Ground Truth");
    count = count + 1;
    
    currentImageDouble = im2double(currentImage);
    currentGround = im2double(groundTruthArray{i});
    diceScore = dice(currentImageDouble, currentGround);
    disp(diceScore);

end

