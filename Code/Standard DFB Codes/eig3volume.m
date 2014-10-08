clear all;
close all;
I=double(imread ('myImage.jpg'));
[Ivessel2,Scales,Direction]=FrangiFilter2D(I);
figure(50),
imshow(Ivessel2,[]);