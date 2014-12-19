%
%       HDR Toolbox demo 4:
%	   1) Load "Venice01.png" LDR image
%      2) Apply Rempel Expansion Operator
%      3) Show the expanded image in false color
%      4) Save the image as .pfm
%
%       Author: Calvin Ching
%
%
disp('1) Load "Venice01.png" LDR image');
imgRem = double(imread('/Users/calvinching/Documents/ubc/eece_541/project/Code/HDR_Toolbox-master/demos/Venice01.png'))/255.0;
h = figure(1);
set(h,'Name','Input LDR image');
imshow(imgRem);

disp('2) Apply Rempel Expansion Operator with gamma=2.2 & noise reduction');
imgRempel = RempelEO(imgRem, 2.2, true, false, 30);

h2 = figure(2);
set(h2, 'Name', 'Output HDR image');
imshow(imgRempel);

disp('3) Show the expanded image in false color');
FalseColor(imgRempel,'log',1,-1,3,'Rempel Inverse tone mapped LDR image in false color');

disp('4) Save the expanded image into a .pfm:');
hdrimwrite(imgRempel,'Venice01_expanded_Rempel.pfm');

disp('5) Applying TMO');
tmoImg = TumblinRushmeierTMO(imgRempel, 25, 100, 100);

h4 = figure(4);
set(h4, 'Name', 'Output TMO image');
imshow(tmoImg);
