%function outImage = hybrid_3x3_matrix(im_path)
clear all;
close all;

tileSize = 5;

im_path = '../HDRImages/bistro_01/bistro_01_000295.hdr';
len = numel(im_path);
file_num = str2double(im_path((len-6):(len-4)));

% Load original image
im = hdrimread(im_path);
luminance = lum(im);
%figure('Name', 'Original Image'),imshow(im);

% Initialize required matrix
[Row, Col, RGB] = size(im);
modified = zeros(Row,Col);
imageOut = zeros(Row,Col,RGB);

% Edge detection applied to original image
%[edge_mask, dir, magGrad] = edge(luminance, 'canny', [0.000008, 0.00005]);
[edge_mask, dir] = canny_edges(im_path, 1.25, 0.05, 1.0);

magGrad = imread('gradient.bmp');
magGrad_double = double(magGrad);
max_g = max(magGrad_double(:));

max_g_threshold = max_g * 0.4;

for j=1:1:Col
    for i=1:1:Row
        if (magGrad(i,j) > max_g_threshold)
            edge_mask(i,j) = 1;
        else
            edge_mask(i,j) = 0;
        end
    end
end
figure('Name', 'Edge Mask'), imshow(edge_mask);

while true
    [edge_mask, num] = close_mask(edge_mask);
    fprintf('num %d\n', num);
    imshow(edge_mask);
    if num < 100
        break;
    end
end
figure('Name', 'Closed Edge Mask'), imshow(edge_mask);

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
ward_img = WardHistAdjTMO(im,5);
ward_img = GammaTMO(ward_img, 2.2, 0, 0);
ward_img = real(ward_img);
ward_img_uint8 = im2uint8(ward_img);
%figure('Name', 'Ward'),imshow(ward_img);

% Apply iCAM on the image and apply Gamma correction
max_lum_ori = max(luminance(:));
iCAM_img_uint8 = iCAM06_HDR(im, max_lum_ori, 0.7, 1.3);
iCAM_img = double(iCAM_img_uint8)/255.0;
iCAM_img = GammaTMO(iCAM_img, 2.2, 0, 0);
iCAM_img = real(iCAM_img);
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
    disp(['Doing column: ' num2str(j)]);
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

% Smoothing algorithm (4 directions attempt - smooth flatly)
% for j=1:1:Col
%     disp(['Doing column: ' num2str(j)]);
%     % Check for pixels around left & right border of the image
%     if j < tileSize + 1
%         jlimit = j - 1;
%     elseif j > Col - tileSize;
%         jlimit = Col - j;
%     else
%         jlimit = tileSize;
%     end
%     for i=1:1:Row
%         % Check for pixels around top & bottom border of the image
%         if i < tileSize + 1
%             ilimit = i - 1;
%         elseif i > Row - tileSize;
%             ilimit = Row - i;
%         else
%             ilimit = tileSize;
%         end
%         if edge_mask(i,j) == 1
%             angle = deg(i,j);
%             if (angle > 45 && angle < 135)
%                 for windowCol=j-jlimit:1:j+jlimit
%                     for windowRow=i:1:i+ilimit
%                         if (windowRow~=i || windowCol~=j)
%                             coneLayer = abs(j-windowCol);
%                             if (coneLayer == 0 || abs(windowRow-i) > abs(windowCol-j))
%                                 coneLayer = windowRow-i;
%                             end
%                             edge_weight = weights(i,j);
%                             end_row = i+ilimit+1;
%                             end_col = j;
%                             if (end_row > Row)
%                                 end_row = Row;
%                             end
%                             end_edge_weight = weights(end_row,end_col);
%                             if edge_mask(end_row,end_col) == 0
%                                 end_edge_weight = 1 - end_edge_weight;
%                             end
%                             factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
%                             if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
%                                 imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
%                                 %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
%                                 modified(windowRow,windowCol) = 1;
%                             else
%                                 imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
%                             end
%                         end
%                     end
%                 end
%             elseif (angle > 135 && angle < 225)
%                 for windowRow=i-ilimit:1:i+ilimit
%                     for windowCol=j-jlimit:1:j
%                         if (windowRow~=i || windowCol~=j)
%                             coneLayer = abs(i-windowRow);
%                             if (coneLayer == 0 || abs(j-windowCol) > abs(windowRow-i))
%                                 coneLayer = j-windowCol;
%                             end
%                             edge_weight = weights(i,j);
%                             end_row = i;
%                             end_col = j-jlimit-1;
%                             if (end_col < 1)
%                                 end_col = 1;
%                             end
%                             end_edge_weight = weights(end_row,end_col);
%                             if edge_mask(end_row,end_col) == 0
%                                 end_edge_weight = 1 - end_edge_weight;
%                             end
%                             factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
%                             if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
%                                 imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
%                                 %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
%                                 modified(windowRow,windowCol) = 1;
%                             else
%                                 imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
%                             end
%                         end
%                     end
%                 end
%             elseif (angle > 225 && angle < 315)
%                 for windowCol=j-jlimit:1:j+jlimit
%                     for windowRow=i-ilimit:1:i
%                         if (windowRow~=i || windowCol~=j)
%                             coneLayer = abs(j-windowCol);
%                             if (coneLayer == 0 || abs(windowRow-i) > abs(windowCol-j))
%                                 coneLayer = i-windowRow;
%                             end
%                             edge_weight = weights(i,j);
%                             end_row = i-ilimit-1;
%                             end_col = j;
%                             if (end_row < 1)
%                                 end_row = 1;
%                             end
%                             end_edge_weight = weights(end_row,end_col);
%                             if edge_mask(end_row,end_col) == 0
%                                 end_edge_weight = 1 - end_edge_weight;
%                             end
%                             factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
%                             if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
%                                 imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
%                                 %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
%                                 modified(windowRow,windowCol) = 1;
%                             else
%                                 imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
%                             end
%                         end
%                     end
%                 end
%             else % 316 - 45
%                 for windowRow=i-ilimit:1:i+ilimit
%                     for windowCol=j-jlimit:1:j
%                         if (windowRow~=i || windowCol~=j)
%                             coneLayer = abs(i-windowRow);
%                             if (coneLayer == 0 || abs(j-windowCol) > abs(windowRow-i))
%                                 coneLayer = windowCol-j;
%                             end
%                             edge_weight = weights(i,j);
%                             end_row = i;
%                             end_col = j+jlimit+1;
%                             if (end_col > Col)
%                                 end_col = Col;
%                             end
%                             end_edge_weight = weights(end_row,end_col);
%                             if edge_mask(end_row,end_col) == 0
%                                 end_edge_weight = 1 - end_edge_weight;
%                             end
%                             factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
%                             if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
%                                 imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
%                                 %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
%                                 modified(windowRow,windowCol) = 1;
%                             else
%                                 imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end
% 

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
        sum = 0;
        if edge_mask(i,j) == 1
            for x=i-1:1:i+1
                for y=j-1:1:j+1
                    sum = edge_mask(x,y) + sum;
                end
            end
        end
        if edge_mask(i,j) == 1 && sum < 8
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
                                edge_weight = weights(i,j);
                                end_row = i;
                                end_col = j+jlimit+1;
                                if (end_col > Col)
                                    end_col = Col;
                                end
                                end_edge_weight = weights(end_row,end_col);
                                if edge_mask(end_row,end_col) == 0
                                    end_edge_weight = 1 - end_edge_weight;
                                end
                                factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
                                if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                    imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                    %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    modified(windowRow,windowCol) = 1;
                                else
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                end
                            end
                        end
                    end
                case 2 % 46 - 90 degrees
                    % Loop for cone area generation for smoothing
                    for windowCol=j:1:(j+jlimit)
                        for windowRow=i:1:(i+ilimit)
                            if (windowRow~=i || windowCol~=j)
                                coneLayer = windowCol - j;
                                if (windowCol-j < windowRow-i)
                                    coneLayer = windowRow - i;
                                end
                                if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                    edge_weight = weights(i,j);
                                    end_row = i+ilimit+1;
                                    end_col = j+jlimit+1;
                                    if (end_col > Col)
                                        end_col = Col;
                                    end
                                    if (end_row > Row)
                                        end_row = Row;
                                    end
                                    end_edge_weight = weights(end_row,end_col);
                                    if edge_mask(end_row,end_col) == 0
                                        end_edge_weight = 1 - end_edge_weight;
                                    end
                                    factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
                                    if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                        imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                        %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
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
                                edge_weight = weights(i,j);
                                end_row = i+ilimit+1;
                                end_col = j;
                                if (end_row > Row)
                                    end_row = Row;
                                end
                                end_edge_weight = weights(end_row,end_col);
                                if edge_mask(end_row,end_col) == 0
                                    end_edge_weight = 1 - end_edge_weight;
                                end
                                factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
                                if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                    imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                    %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    modified(windowRow,windowCol) = 1;
                                else
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                end
                            end
                        end
                    end
                case 4 % 136 - 180 degrees
                    % Loop for cone area generation for smoothing
                    for windowCol=j:-1:(j-jlimit)
                        for windowRow=i:1:(i+ilimit)
                            if (windowRow~=i || windowCol~=j)
                                coneLayer = j - windowCol;
                                if (j-windowCol < windowRow-i)
                                    coneLayer = windowRow - i;
                                end
                                if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                    edge_weight = weights(i,j);
                                    end_row = i+ilimit+1;
                                    end_col = j-jlimit-1;
                                    if (end_col < 1)
                                        end_col = 1;
                                    end
                                    if (end_row > Row)
                                        end_row = Row;
                                    end
                                    end_edge_weight = weights(end_row,end_col);
                                    if edge_mask(end_row,end_col) == 0
                                        end_edge_weight = 1 - end_edge_weight;
                                    end
                                    factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
                                    if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                        imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                        %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
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
                                edge_weight = weights(i,j);
                                end_row = i;
                                end_col = j-jlimit-1;
                                if (end_col < 1)
                                    end_col = 1;
                                end
                                end_edge_weight = weights(end_row,end_col);
                                if edge_mask(end_row,end_col) == 0
                                    end_edge_weight = 1 - end_edge_weight;
                                end
                                factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
                                if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                    imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                    %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    modified(windowRow,windowCol) = 1;
                                else
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                end
                            end
                        end
                    end
                case 6 % 226 - 270 degrees
                    % Loop for cone area generation for smoothing
                    for windowCol=j:-1:(j-jlimit)
                        for windowRow=i:-1:(i-ilimit)
                            if (windowRow~=i || windowCol~=j)
                                coneLayer = j - windowCol;
                                if (j-windowCol < i-windowRow)
                                    coneLayer = i - windowRow;
                                end
                                if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                    edge_weight = weights(i,j);
                                    end_row = i-ilimit-1;
                                    end_col = j-jlimit-1;
                                    if (end_col < 1)
                                        end_col = 1;
                                    end
                                    if (end_row < 1)
                                        end_row = 1;
                                    end
                                    end_edge_weight = weights(end_row,end_col);
                                    if edge_mask(end_row,end_col) == 0
                                        end_edge_weight = 1 - end_edge_weight;
                                    end
                                    factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
                                    if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                        imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                        %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
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
                                edge_weight = weights(i,j);
                                end_row = i-ilimit-1;
                                end_col = j;
                                if (end_row < 1)
                                    end_row = 1;
                                end
                                end_edge_weight = weights(end_row,end_col);
                                if edge_mask(end_row,end_col) == 0
                                    end_edge_weight = 1 - end_edge_weight;
                                end
                                factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
                                if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                    imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                    %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                    modified(windowRow,windowCol) = 1;
                                else
                                    imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
                                end
                            end
                        end
                    end
                case 8 % 316 - 360 degrees
                    % Loop for cone area generation for smoothing
                    for windowCol=j:1:(j + jlimit)
                        for windowRow=i:-1:(i - ilimit)
                            if (windowRow~=i || windowCol~=j)
                                coneLayer = windowCol - j;
                                if (windowCol-j < i-windowRow)
                                    coneLayer = i - windowRow;
                                end
                                if windowRow >= 1 && windowRow <= Row && windowCol >= 1 && windowCol <= Col
                                    edge_weight = weights(i,j);
                                    end_row = i-ilimit-1;
                                    end_col = j+jlimit+1;
                                    if (end_col > Col)
                                        end_col = Col;
                                    end
                                    if (end_row < 1)
                                        end_row = 1;
                                    end
                                    end_edge_weight = weights(end_row,end_col);
                                    if edge_mask(end_row,end_col) == 0
                                        end_edge_weight = 1 - end_edge_weight;
                                    end
                                    factor = edge_weight - (coneLayer * (abs(edge_weight - end_edge_weight)/(tileSize+1)));
                                    if modified(windowRow,windowCol) == 0 && edge_mask(windowRow,windowCol) ~= 1;
                                        imageOut(windowRow,windowCol,:) = factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:);
                                        %imageOut(windowRow,windowCol,:)= ((factor * iCAM_img(windowRow,windowCol,:) + (1-factor) * ward_img(windowRow,windowCol,:)) + imageOut(windowRow,windowCol,:)) / 2;
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

%figure('Name', 'Unprocessed hybrid image'),imshow(imageOut);

% Grab the ROI
%roi = roipoly(imageOut);

if (file_num < 315)
    load('roi_face.mat');
    imageOut = im_process(imageOut, roi_face, 1, 24);
elseif (file_num < 320)
    load('roi_face315.mat');
    imageOut = im_process(imageOut, roi_face315, 1, 24);
elseif (file_num < 434)
    load('roi_face320.mat');
    imageOut = im_process(imageOut, roi_face320, 1, 24);
end

if (file_num < 315)
    load('roi_hair.mat');
    imageOut = im_process(imageOut, roi_hair, 0.75, 12);
elseif (file_num < 320)
    load('roi_hair315.mat');
    imageOut = im_process(imageOut, roi_hair315, 0.75, 12);
elseif (file_num < 434)
    load('roi_hair320.mat');
    imageOut = im_process(imageOut, roi_hair320, 0.75, 12);
end

load('roi_bottle.mat');
roi_bottle = roi;
imageOut = im_process(imageOut, roi_bottle, 0.5, 6);

% Final image process. Enhance dark area
srgb2lab = makecform('srgb2lab');
lab2srgb = makecform('lab2srgb');
im_lab = applycform(imageOut, srgb2lab); % convert to L*a*b*

max_luminosity = 100;
L = im_lab(:,:,1)/max_luminosity;

im_lab(:,:,1) = imadjust(L,[0.075;0.975],[0;1])*max_luminosity;
imageOut = applycform(im_lab, lab2srgb); % convert back to RGB

figure('Name', 'Final hybrid image'),imshow(imageOut);

outImage = imageOut;