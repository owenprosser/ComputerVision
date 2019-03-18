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

for i = 1:size(imagesArray, 2)
    currentImage = imagesArray{i};
    figure;
    
    currentImage = currentImage(:,:,3);
    currentImage = imbinarize(currentImage);
    
    imshow(currentImage);
end

