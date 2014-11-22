%function outImage = hybrid_3x3_matrix(filename)
clear all;
close all;

tileSize = 5;

im_path = 'bistro_01_000295.hdr';

% Load original image
im = hdrimread(im_path);
luminance = lum(im);
%figure('Name', 'Original Image'),imshow(im);

% Initialize required matrix
[Row, Col, RGB] = size(im);
modified = zeros(Row,Col);
imageOut = zeros(Row,Col,RGB);

% Edge detection applied to original image
%[edge_mask, dir] = edge(luminance, 'canny', [0.0000001, 0.055]);
[edge_mask, dir] = canny_edges(im_path, 1.5, 0.05, 1.0);

g = imread('gradient.bmp');
max_g = max(g(:));
max_g_threshold = max_g * 0.5;
for j=1:1:Col
    for i=1:1:Row
        if (g(i,j) > max_g_threshold)
            edge_mask(i,j) = 1;
        else
            edge_mask(i,j) = 0;
        end
    end
end

%figure('Name', 'Edge Mask'), imshow(edge_mask);

% Convert rad to deg and convert to 0 to 360 degrees
deg = radtodeg(dir);
for j=1:1:Col
    for i=1:1:Row
        if deg(i,j) < 0
            deg(i,j) = 360 + deg(i,j);
        end
    end
end 
[v,ind]=max(deg);
[v1,ind1]=max(max(deg));
disp(sprintf('The largest element in deg matrix is %f at (%d,%d).', v1, ind(ind1), ind1 ));

% Apply Ward on the image and apply Gamma correction
ward_img = WardHistAdjTMO(im);
ward_img = GammaTMO(ward_img, 2.2, 0, 0);
ward_img = real(ward_img);
ward_img_uint8 = im2uint8(ward_img);

% Apply iCAM on the image and apply Gamma correction
max_lum_ori = max(luminance(:));
iCAM_img_uint8 = iCAM06_HDR(im, max_lum_ori, 0.7, 1);
iCAM_img = double(iCAM_img_uint8)/255.0;
iCAM_img = GammaTMO(iCAM_img, 2.2, 0, 0);

%figure('Name', 'Ward'),imshow(ward_img);
%figure('Name', 'iCAM'),imshow(iCAM_img);

% Get the luminance values of the Ward and iCAM images
lum_iCAM = lum(iCAM_img_uint8);
lum_ward = lum(ward_img_uint8);
lum_iCAM = double(lum_iCAM);
lum_ward = double(lum_ward);

% Get the difference between the luminance so we know how much weighting to
% use
diff = abs(lum_iCAM - lum_ward);
[max_diff, loc_diff] = max(diff(:));

weights = zeros(Row,Col);
% Generate final image based on edge mask with weighting
for j=1:Col
    for i=1:Row
        % Calculate edge weight based on difference between the luminance
        % of iCAM and Ward. The edge_weight should be between 1.0 and 0.5.
        % Right now, it's a linear inverse relationship between edge_weight
        % and difference.
        weight = -(diff(i,j)/(max_diff * 2)) + 1.0;
        if(edge_mask(i,j) == 1)
            imageOut(i,j,:) = weight*iCAM_img(i,j,:) + (1-weight)*ward_img(i,j,:);
        else
            imageOut(i,j,:) = weight*ward_img(i,j,:) + (1-weight)*iCAM_img(i,j,:);
        end
        weights(i,j) = weight;
    end
end

% i_R = imageOut(:,:,1);
% i_G = imageOut(:,:,2);
% i_B = imageOut(:,:,3);
%figure('Name', 'Unsmoothed Image'),imshow(imageOut);

% Smoothing algorithm
for j=1:1:Col
    disp(['Doing column: ' num2str(j)]);
    % Check for pixels around left & right border of the image
    if j < tileSize + 1
        jlimit = j - 1;
    elseif j > Col - tileSize;
        jlimit = Col - j;
    else
        jlimit = tileSize;
    end
    for i=1:1:Row
        % Check for pixels around top & bottom border of the image
        if i < tileSize + 1
            ilimit = i - 1;
        elseif i > Row - tileSize;
            ilimit = Row - i;
        else
            ilimit = tileSize;
        end
        if edge_mask(i,j) == 1
            angle = deg(i,j);
            mode = ceil(angle/45);
            switch mode
                case 1 % 1 - 45 degrees
                    coneLayer = 0;
                    % Loop for cone area generation for smoothing
                    for windowCol=(j+1):1:(j+jlimit)
                        coneLayer = coneLayer + 1;
                        for windowRow=(i-coneLayer):1:(i+coneLayer)
                            if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                edge_weight = weights(windowRow,windowCol);
                                factor = edge_weight - (coneLayer * ((edge_weight - (1 - edge_weight))/tileSize));
                                if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                    %imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    modified(windowRow,windowCol) = 1;
                                else
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                end
                            end
                        end
                    end
                case 2 % 46 - 90 degrees
                    coneLayer = 0;
                    % Loop for cone area generation for smoothing
                    for windowCol=j:1:(j+jlimit)
                        for windowRow=i:1:(i+ilimit)
                            if (windowRow~=i || windowCol~=j)
                                coneLayer = windowCol - j;
                                if (windowCol-j < windowRow-i)
                                    coneLayer = windowRow - i;
                                end
                                if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                    edge_weight = weights(windowRow,windowCol);
                                    factor = edge_weight - (coneLayer * ((edge_weight - (1 - edge_weight))/tileSize));
                                    if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                        %imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                        imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                        modified(windowRow,windowCol) = 1;
                                    else
                                        imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    end
                                end
                            end
                        end
                    end
                case 3 % 91 - 135 degrees
                    coneLayer = 0;
                    % Loop for cone area generation for smoothing
                    for windowRow=(i+1):1:(i+ilimit)
                        coneLayer = coneLayer + 1;
                        for windowCol=(j-coneLayer):1:(j+coneLayer)
                            if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                edge_weight = weights(windowRow,windowCol);
                                factor = edge_weight - (coneLayer * ((edge_weight - (1 - edge_weight))/tileSize));
                                if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                    % imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    modified(windowRow,windowCol) = 1;
                                else
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                end
                            end
                        end
                    end
                case 4 % 136 - 180 degrees
                    coneLayer = 0;
                    % Loop for cone area generation for smoothing
                    for windowCol=j:-1:(j-jlimit)
                        for windowRow=i:1:(i+ilimit)
                            if (windowRow~=i || windowCol~=j)
                                coneLayer = j - windowCol;
                                if (j-windowCol < windowRow-i)
                                    coneLayer = windowRow - i;
                                end
                                if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                    edge_weight = weights(windowRow,windowCol);
                                    factor = edge_weight - (coneLayer * ((edge_weight - (1 - edge_weight))/tileSize));
                                    if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                        %imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                        imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                        modified(windowRow,windowCol) = 1;
                                    else
                                        imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    end
                                end
                            end
                        end
                    end
                case 5 % 181 - 225 degrees
                    coneLayer = 0;
                    % Loop for cone area generation for smoothing
                    for windowCol=(j-1):-1:(j-jlimit)
                        coneLayer = coneLayer + 1;
                        for windowRow=(i-coneLayer):1:(i+coneLayer)
                            if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                edge_weight = weights(windowRow,windowCol);
                                factor = edge_weight - (coneLayer * ((edge_weight - (1 - edge_weight))/tileSize));
                                if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                    %imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    modified(windowRow,windowCol) = 1;
                                else
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                end
                            end
                        end
                    end
                case 6 % 226 - 270 degrees
                    coneLayer = 0;
                    % Loop for cone area generation for smoothing
                    for windowCol=j:-1:(j-jlimit)
                        for windowRow=i:-1:(i-ilimit)
                            if (windowRow~=i || windowCol~=j)
                                coneLayer = j - windowCol;
                                if (j-windowCol < i-windowRow)
                                    coneLayer = i - windowRow;
                                end
                                if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                    edge_weight = weights(windowRow,windowCol);
                                    factor = edge_weight - (coneLayer * ((edge_weight - (1 - edge_weight))/tileSize));
                                    if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                        %imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                        imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                        modified(windowRow,windowCol) = 1;
                                    else
                                        imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    end
                                end
                            end
                        end
                    end
                case 7 % 271 - 315 degrees
                    coneLayer = 0;
                    % Loop for cone area generation for smoothing
                    for windowRow=(i-1):1:(i-ilimit)
                        coneLayer = coneLayer + 1;
                        for windowCol=(j-coneLayer):1:(j+coneLayer)
                            if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                edge_weight = weights(windowRow,windowCol);
                                factor = edge_weight - (coneLayer * ((edge_weight - (1 - edge_weight))/tileSize));
                                if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                    %imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    modified(windowRow,windowCol) = 1;
                                else
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                end
                            end
                        end
                    end
                case 8 % 316 - 360 degrees
                    coneLayer = 0;
                    % Loop for cone area generation for smoothing
                    for windowCol=j:1:(j + jlimit)
                        for windowRow=i:-1:(i - ilimit)
                            if (windowRow~=i || windowCol~=j)
                                coneLayer = windowCol - j;
                                if (windowCol-j < i-windowRow)
                                    coneLayer = i - windowRow;
                                end
                                if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                    edge_weight = weights(windowRow,windowCol);
                                    factor = edge_weight - (coneLayer * ((edge_weight - (1 - edge_weight))/tileSize));
                                    if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                        %imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                        imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                        modified(windowRow,windowCol) = 1;
                                    else
                                        imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    end
                                end
                            end
                        end
                    end
                otherwise
                    disp('Angle not classified into a mode!');
            end
        end
    end
end

figure('Name', 'Unprocessed hybrid image'),imshow(imageOut);

% Grab the ROI
%roi = roipoly(imageOut);
load('roi2.mat');
partImg = double(zeros(Row,Col,3));
partImg2 = double(zeros(Row,Col,3));
partImg3 = double(zeros(Row,Col,3));
%figure('Name', 'roi'),imshow(roi);

se = strel('disk',4);
roi2 = imdilate(roi, se);
%figure('Name', 'roi2'),imshow(roi2);

se = strel('disk',6);
roi3 = imdilate(roi2, se);
%figure('Name', 'roi3'),imshow(roi3);

% Based on the ROI, grab the partImg
partImg(:,:,1) = imageOut(:,:,1).*roi;
partImg(:,:,2) = imageOut(:,:,2).*roi;
partImg(:,:,3) = imageOut(:,:,3).*roi;
figure('Name', 'Part img'),imshow(partImg);

% Based on the ROI2, grab the partImg2
partImg2(:,:,1) = imageOut(:,:,1).*roi2;
partImg2(:,:,2) = imageOut(:,:,2).*roi2;
partImg2(:,:,3) = imageOut(:,:,3).*roi2;
figure('Name', 'Part img 2'),imshow(partImg2);

% Based on the ROI3, grab the partImg3
partImg3(:,:,1) = imageOut(:,:,1).*roi3;
partImg3(:,:,2) = imageOut(:,:,2).*roi3;
partImg3(:,:,3) = imageOut(:,:,3).*roi3;
figure('Name', 'Part img 3'),imshow(partImg3);

% Sharpen partImg
partImg = imsharpen(partImg, 'Radius', 1.5, 'Amount', 2.0);
% Change pixel color format to 0 to 255
partImg = im2uint8(partImg);
% Apply contrast to partImg
partImg = im_contrast(partImg, 50);
figure('Name', 'Processed part image 1'),imshow(partImg);

% Sharpen partImg2
partImg2 = imsharpen(partImg2, 'Radius', 1.5, 'Amount', 1.5);
% Change pixel color format to 0 to 255
partImg2 = im2uint8(partImg2);
% Apply contrast to partImg2
partImg2 = im_contrast(partImg2, 30);
figure('Name', 'Processed part image 2'),imshow(partImg2);

% Sharpen partImg3
partImg3 = imsharpen(partImg3, 'Radius', 1.5, 'Amount', 0.75);
% Change pixel color format to 0 to 255
partImg3 = im2uint8(partImg3);
% Apply contrast to partImg3
partImg3 = im_contrast(partImg3, 10);
figure('Name', 'Contrasted part image 3'),imshow(partImg3);

% There is a white edge around the processed partImg. We need to get rid of
% it
edge_partImg = edge(lum(partImg), 'canny', [0.0000001, 0.5]);
se = strel('disk',4);
edge_partImg = imdilate(edge_partImg, se);
figure('Name', 'Edge part image1'),imshow(edge_partImg);
edge_partImg = ~edge_partImg;
roi = roi.*edge_partImg;

% There is a white edge around the processed partImg. We need to get rid of
% it
edge_partImg2 = edge(lum(partImg2), 'canny', [0.0000001, 0.5]);
se = strel('disk',3);
edge_partImg2 = imdilate(edge_partImg2, se);
figure('Name', 'Edge part image2'),imshow(edge_partImg2);
edge_partImg2 = ~edge_partImg2;
roi2 = roi2.*edge_partImg2;

% There is a white edge around the processed partImg. We need to get rid of
% it
edge_partImg3 = edge(lum(partImg3), 'canny', [0.0000001, 0.5]);
se = strel('disk',3);
edge_partImg3 = imdilate(edge_partImg3, se);
figure('Name', 'Edge part image3'),imshow(edge_partImg3);
edge_partImg3 = ~edge_partImg3;
roi3 = roi3.*edge_partImg3;

% Create the final image by combining hybrid smoothed image with processed
% partImg
imageOut = im2uint8(imageOut);
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
            finalImg(i,j,1) = imageOut(i,j,1);
            finalImg(i,j,2) = imageOut(i,j,2);
            finalImg(i,j,3) = imageOut(i,j,3);
        end
    end
end
figure('Name', 'Final hybrid image'),imshow(finalImg);

outImage = imageOut;