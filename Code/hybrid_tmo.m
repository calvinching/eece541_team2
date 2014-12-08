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
norm_G = zeros(Row,Col);
norm_L = zeros(Row,Col);

% Edge detection applied to original image
%[edge_mask, dir, magGrad] = edge(luminance, 'canny', [0.000008, 0.00005]);
[edge_mask, dir] = canny_edges(im_path, 1.25, 0.05, 1.0);

magGrad = imread('gradient.bmp');
magGrad_double = double(magGrad);
min_g = min(magGrad_double(:));
max_g = max(magGrad_double(:));
min_l = min(luminance(:));
max_l = max(luminance(:));
diff_g = (max_g - min_g);
diff_l = (max_l - min_l);

% normalize magGrad
for j=1:1:Col
    for i=1:1:Row
        norm_G(i,j) = (magGrad_double(i,j) - min_g)/diff_g;
        norm_L(i,j) = (luminance(i,j) - min_l)/diff_l;
    end
end

max_g_threshold = max_g * 0.4;
% for exp=0.1:0.1:1
exp=2;
for j=1:1:Col
    for i=1:1:Row
        threshold = norm_L(i,j)^exp;
        if (norm_G(i,j) > threshold)
            edge_mask(i,j) = 1;
        else
            edge_mask(i,j) = 0;
        end
    end
end
% file = sprintf('../img/edge_mask%d.png',exp);
% imwrite(edge_mask, file);
% end
% for j=1:1:Col
%     for i=1:1:Row
%         if (magGrad(i,j) > max_g_threshold)
%             edge_mask(i,j) = 1;
%         else
%             edge_mask(i,j) = 0;
%         end
%     end
% end
%figure('Name', 'Edge Mask'), imshow(edge_mask);
% 
% max_iter = 50;
% iter = 0;
% while true
%     [edge_mask, num] = close_mask(edge_mask);
%     fprintf('num %d\n', num);
%     %imshow(edge_mask);
%     if num < 100
%         break;
%     end
%     iter = iter + 1;
% end
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

num_neighbors = 20;
max_neighbors = (num_neighbors * 2 + 1)^2 - 1;
max_neighbors = double(max_neighbors);
for j=1:Col
    disp(['Doing column: ' num2str(j)]);
    for i=1:Row
        weight = check_neighbors(edge_mask, i, j, num_neighbors);
        imageOut(i,j,:) = weight*iCAM_img(i,j,:) + (1-weight)*ward_img(i,j,:);
    end
end
figure('Name', 'Combined image'),imshow(imageOut);
imsharpen(imageOut, 'Radius', 1.5, 'Amount', 2.0);
figure('Name', 'Sharpened image'),imshow(imageOut);

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