close all;
clear all;
% im = imread('101_3.tif');
%im = imread('/Users/calvinching/Documents/ubc/eece_541/project/HDRImages/bistro_01/bistro_01_000295.hdr');
im = read_radiance('/Users/calvinching/Documents/ubc/eece_541/project/HDRImages/bistro_01/bistro_01_000295.hdr');
%im = read_radiance('/Users/calvinching/Documents/ubc/eece_541/project/HDRImages/desk.hdr');
%im = double(imread('/Users/calvinching/Documents/ubc/eece_541/project/Code/HDR_Toolbox-master/demos/Venice01.png'))/255.0;scale = [1, 1.4142, 2, 2*1.4142, 4,4*1.41412];

luminance = lum(im);
imshow(luminance);
%Frangi filter
%res1 = Frangi_filter(luminance,scale,1);
%figure(2),imshow(res1,[]);

%Shikata filter
%res2 = Shikata_filter(im,scale);

%our filter
%res3 = dfb_based_filter_new2(luminance, scale, 3, 1);
%figure,imshow(res3,[]);
%imshow(luminance);

edge_mask = edge(luminance, 'canny');
% edge_mask = edge(luminance, 'sobel', 0.35);
figure,imshow(edge_mask);
inv_edge_mask = ~edge_mask;

iCAM_img = iCAM06_HDR(im, 20000, 0.7, 1);
iCAM_img = double(iCAM_img)/255.0;
ward_img = WardHistAdjTMO(im);
figure('Name', 'iCam'),imshow(iCAM_img);
figure('Name', 'ward'),imshow(ward_img);

[x,y,z] = size(iCAM_img);
hybrid_img = zeros(x,y,z);
for i = 1:x
   for j =1:y
       if (edge_mask(i, j) == 1)
%            R = iCAM_img(:,:,1);
%            G = iCAM_img(:,:,2);
%            B = iCAM_img(:,:,3);
%            r = R(i,j);
%            g = G(i,j);
%            b = B(i,j);
           hybrid_img(i,j,:) = iCAM_img(i,j,:);
       else
           hybrid_img(i,j,:) = ward_img(i,j,:);
       end
   end
end

figure('Name', 'hybrid'),imshow(hybrid_img);



