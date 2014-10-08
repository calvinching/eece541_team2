clc;
close all;
% k=input('Enter the file name','s'); % input image; color image
im=imread('vessel.jpg');
im1=rgb2gray(im);
im1=medfilt2(im1,[9 9]); %Median filtering the image to remove noise%
BW = edge(im1,'sobel'); %finding edges 
[imx,imy]=size(BW);
msk=[0 0 0 0 0;
     0 1 1 1 0;
     0 1 1 1 0;
     0 1 1 1 0;
     0 0 0 0 0;];
B=conv2(double(BW),double(msk)); %Smoothing  image to reduce the number of connected components
figure,imshow(im);
figure,imshow(im1);
figure,imshow(B);