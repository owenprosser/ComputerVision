clear all; close all;
a = imread('ISIC_0000416.jpg');
b = imread('ISIC_0011210.jpg');
c = imread('ISIC_0011357.jpg');
a_GT = imread('ISIC_0000416_Segmentation.png');
b_GT = imread('ISIC_0011210_Segmentation.png');
c_GT = imread('ISIC_0011357_Segmentation.png');

img = a;
groundTruth = a_GT;
figure, imshow(img);
imsegmentation(img, groundTruth);
img = b;
groundTruth = b_GT;
figure, imshow(img);
imsegmentation(img, groundTruth);
img = c;
groundTruth = c_GT;
figure, imshow(img);
imsegmentation(img, groundTruth);

function imsegmentation(img, groundTruth)
    grayscale = rgb2gray(img);
    mediatedImage = medfilt2(grayscale);
    se = strel('disk', 10);
    hairs = imbothat(mediatedImage,se);
    figure, imshow(hairs);

    hairs = imbinarize(hairs, 'adaptive');
    hairs = bwmorph(bwmorph(hairs,'thicken'),'thicken');
    img(repmat(hairs,1,1,3)) = 0;
    figure, imshow(img);
    R = img(:,:,1); % splitting RGB because regionfill need grayscale.
    G = img(:,:,2);
    B = img(:,:,3);
    mask = uint8(R) == 0;
    R_autofill = regionfill(R,mask);
    mask = uint8(G) == 0;
    G_autofill = regionfill(G,mask);
    mask = uint8(B) == 0;
    B_autofill = regionfill(B,mask);
    newimage_autofill(:,:,1)=R_autofill;
    newimage_autofill(:,:,2)=G_autofill;
    newimage_autofill(:,:,3)=B_autofill;

    %figure, imshow(newimage_autofill);
    img = newimage_autofill;
    lab_he = rgb2lab(img);
    figure, imshow(lab_he);

    ab = lab_he(:,:,2:3);
    ab = im2single(ab);
    nColors = 3;
    pixel_labels = imsegkmeans(ab,nColors,'NumAttempts',3);
    imshow(pixel_labels,[])
    title('Image Labeled by Cluster Index');

    mask = pixel_labels==2;
    cluster = img .* uint8(mask);
    imshow(cluster)
    title('Object in Cluster');

    C = rgb2gray(cluster);
    B = imbinarize(C);
    B = imfill(B, 'holes');
    figure;
    imshow(B)
    title('Labeled Image')

    groundTruth = imbinarize(groundTruth, 'global');
    similarity = dice(B, groundTruth);
    figure;
    imshowpair(B, groundTruth);
    title(['Dice Index = ' num2str(similarity)]);
end