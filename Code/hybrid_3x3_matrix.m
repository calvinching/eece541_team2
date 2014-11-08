
close all;
clear all;

%im = hdrimread('Bottles_Small.hdr');
im = hdrimread('/Users/calvinching/Documents/ubc/eece_541/project/HDRImages/bistro_01/bistro_01_000295.hdr');
luminance = lum(im);

figure;
imshow(im);
title('Original Image');

[edge_mask, dir] = edge(luminance, 'canny');
deg = radtodeg(dir);
figure('Name', 'Edge Mask'),imshow(edge_mask);

[Row, Col, RGB]=size(im);

Frame1= zeros(Row,Col);
Frame2= zeros(Row,Col,RGB);

% 3x3 masking of the edge 
for j=2:Col-1
    for i=2:Row-1
        if((edge_mask(i, j) == 1)||((edge_mask(i, j-1) == 1)||(edge_mask(i, j+1) == 1)||(edge_mask(i-1, j-1) == 1)||(edge_mask(i-1, j) == 1)||(edge_mask(i-1, j+1) == 1)||(edge_mask(i+1, j-1) == 1)||(edge_mask(i+1,j) == 1)||(edge_mask(i+1,j+1) == 1)))
            r = randi([1,9],1,2);
            if (r(1,1) == 1 || r(1,2) == 1)
                Frame1(i, j) = 1;
            end
            if (r(1,1) == 2 || r(1,2) == 2)
                Frame1(i, j-1) = 1;
            end
            if (r(1,1) == 3 || r(1,2) == 3)
                Frame1(i, j+1) = 1;
            end
            if (r(1,1) == 4 || r(1,2) == 4)
                Frame1(i-1, j-1) =1;
            end
            if (r(1,1) == 5 || r(1,2) == 5)
                Frame1(i-1, j) = 1;
            end
            if (r(1,1) == 6 || r(1,2) == 6)
                Frame1(i-1, j+1) =1;
            end
            if (r(1,1) == 7 || r(1,2) == 7)
                Frame1(i+1, j-1) = 1;
            end
            if (r(1,1) == 8 || r(1,2) == 8)
                Frame1(i+1, j) = 1;
            end
            if (r(1,1) == 9 || r(1,2) == 9)
                Frame1(i+1, j+1) = 1;
            end
        else
             Frame1(i, j) = 0;
             Frame1(i, j-1) = 0;
             Frame1(i, j+1) = 0;
             Frame1(i-1, j-1) = 0;
             Frame1(i-1, j) = 0;
             Frame1(i-1, j+1) = 0;
             Frame1(i+1, j-1) = 0; 
             Frame1(i+1, j) = 0;
             Frame1(i+1, j+1) = 0;
        end
    end
end

for j=1:1
    for i=1:1
        if((edge_mask(i, j) == 1)||((edge_mask(i, j+1) == 1)||(edge_mask(i+1, j) == 1)||(edge_mask(i+1,j+1) == 1)))
               Frame1(i, j) = 1; 
               Frame1(i, j+1) =1;
               Frame1(i+1, j) =1;
               Frame1(i+1,j+1) =1;
        else
               Frame1(i, j)= 0; 
               Frame1(i, j+1)=0;
               Frame1(i+1, j)=0;
               Frame1(i+1,j+1)=0;
        end
    end
end
%   counter=0;
%    for j=1:Col    
%     for i=1:Row
%         
%              if(Frame1(i, j) == 1)
%                  counter=counter+1;
%              end
%     end 
%    end 
   
iCAM_img = iCAM06_HDR(im, 20000, 0.7, 1);
iCAM_img = double(iCAM_img)/255.0;
ward_img = WardHistAdjTMO(im, 5);

for j=1:Col
    for i=1:Row
        if(Frame1(i,j) == 1)
            Frame2(i,j,:)= (0.65)*iCAM_img(i,j,:) + (0.35)*ward_img(i,j,:);
        else
            Frame2(i,j,:)= (0.80)*ward_img(i,j,:) + (0.20)*iCAM_img(i,j,:);
        end
    end
end
    
figure('Name', 'Sectored image'),imshow(Frame1);
figure('Name', 'Hybrid image'),imshow(Frame2);
figure('Name', 'Ward'),imshow(ward_img);
figure('Name', 'iCAM'),imshow(iCAM_img);
