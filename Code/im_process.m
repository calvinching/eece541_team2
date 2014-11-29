function [ finalImg ] = im_process( im, roi, sharp_amt, contrast_amt )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[Row, Col, RGB] = size(im);

partImg = double(zeros(Row,Col,RGB));
partImg2 = double(zeros(Row,Col,RGB));
partImg3 = double(zeros(Row,Col,RGB));
%figure('Name', 'roi'),imshow(roi);

se = strel('disk',4);
roi2 = imdilate(roi, se);
%figure('Name', 'roi2'),imshow(roi2);

se = strel('disk',6);
roi3 = imdilate(roi2, se);
%figure('Name', 'roi3'),imshow(roi3);

% Based on the ROI, grab the partImg
partImg(:,:,1) = im(:,:,1).*roi;
partImg(:,:,2) = im(:,:,2).*roi;
partImg(:,:,3) = im(:,:,3).*roi;
%figure('Name', 'Part img'),imshow(partImg);

% Based on the ROI2, grab the partImg2
partImg2(:,:,1) = im(:,:,1).*roi2;
partImg2(:,:,2) = im(:,:,2).*roi2;
partImg2(:,:,3) = im(:,:,3).*roi2;
%figure('Name', 'Part img 2'),imshow(partImg2);

% Based on the ROI3, grab the partImg3
partImg3(:,:,1) = im(:,:,1).*roi3;
partImg3(:,:,2) = im(:,:,2).*roi3;
partImg3(:,:,3) = im(:,:,3).*roi3;
%figure('Name', 'Part img 3'),imshow(partImg3);

% Sharpen partImg
partImg = imsharpen(partImg, 'Radius', 1.5, 'Amount', sharp_amt);
% Change pixel color format to 0 to 255
partImg = im2uint8(partImg);
% Apply contrast to partImg2
partImg = im_contrast(partImg, contrast_amt);
% partImgLap = rgblaplacian(partImg);
% figure('Name', 'Sharpened Lap image 1'),imshow(partImgLap);
% partImgLap = im2uint8(partImgLap);
% partImgLap = im_contrast(partImgLap, 24);
% figure('Name', 'Processed Lap part image 1'),imshow(partImgLap);

% Sharpen partImg2
partImg2 = imsharpen(partImg2, 'Radius', 1.5, 'Amount', sharp_amt*0.8);
% Change pixel color format to 0 to 255
partImg2 = im2uint8(partImg2);
% Apply contrast to partImg2
partImg2 = im_contrast(partImg2, contrast_amt*0.5);
%figure('Name', 'Processed part image 2'),imshow(partImg2);

% Sharpen partImg3
partImg3 = imsharpen(partImg3, 'Radius', 1.5, 'Amount', sharp_amt*0.5);
% Change pixel color format to 0 to 255
partImg3 = im2uint8(partImg3);
% Apply contrast to partImg3
partImg3 = im_contrast(partImg3, contrast_amt*0.25);

%figure('Name', 'Contrasted part image 3'),imshow(partImg3);

% There is a white edge around the processed partImg. We need to get rid of
% it
edge_partImg = edge(lum(partImg), 'canny', [0.0000001, 0.5]);
se = strel('disk',4);
edge_partImg = imdilate(edge_partImg, se);
%figure('Name', 'Edge part image1'),imshow(edge_partImg);
edge_partImg = ~edge_partImg;
roi = roi.*edge_partImg;

% There is a white edge around the processed partImg. We need to get rid of
% it
edge_partImg2 = edge(lum(partImg2), 'canny', [0.0000001, 0.5]);
se = strel('disk',3);
edge_partImg2 = imdilate(edge_partImg2, se);
%figure('Name', 'Edge part image2'),imshow(edge_partImg2);
edge_partImg2 = ~edge_partImg2;
roi2 = roi2.*edge_partImg2;

% There is a white edge around the processed partImg. We need to get rid of
% it
edge_partImg3 = edge(lum(partImg3), 'canny', [0.0000001, 0.5]);
se = strel('disk',3);
edge_partImg3 = imdilate(edge_partImg3, se);
%figure('Name', 'Edge part image3'),imshow(edge_partImg3);
edge_partImg3 = ~edge_partImg3;
roi3 = roi3.*edge_partImg3;

% Create the final image by combining hybrid smoothed image with processed
% partImg
im = im2uint8(im);
finalImg = uint8(zeros(Row,Col,3));
for j=1:Col
    for i=1:Row
        if (roi(i,j) == 1)
            finalImg(i,j,1) = partImg(i,j,1);
            finalImg(i,j,2) = partImg(i,j,2);
            finalImg(i,j,3) = partImg(i,j,3);
        elseif (roi2(i,j) == 1)
            finalImg(i,j,1) = partImg2(i,j,1);
            finalImg(i,j,2) = partImg2(i,j,2);
            finalImg(i,j,3) = partImg2(i,j,3);
        elseif (roi3(i,j) == 1)
            finalImg(i,j,1) = partImg3(i,j,1);
            finalImg(i,j,2) = partImg3(i,j,2);
            finalImg(i,j,3) = partImg3(i,j,3);
        else
            finalImg(i,j,1) = im(i,j,1);
            finalImg(i,j,2) = im(i,j,2);
            finalImg(i,j,3) = im(i,j,3);
        end
    end
end

finalImg = double(finalImg)/255.0;

end

