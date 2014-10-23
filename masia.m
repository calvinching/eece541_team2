%      1) Load "Venice01.png" LDR image
%      2) Apply Masia Expansion Operator
%      3) Show the expanded image in false color
%      4) Save the image as .pfm
%
%       Author: Stelios Ploumis
%
%
disp('1) Load "Venice01.png" LDR image');
imgRem = double(imread('/.../HDR_Toolbox-master/demos/Venice01.png'))/255.0;
h = figure(1);
FalseColor(imgRem,'lin',1,-1,1,'ldr');

% set(h,'Name','Input LDR image');
% imshow(imgRem);

disp('2) Apply Masia Expansion Operator');
imgMasia = MasiaEO(imgRem);

% rgb = tonemap(imgMasia);
% h2 = figure(2);
% set(h2,'Name','output tonne mapped image');
% imshow(rgb);

disp('3) Show the expanded image in false color');
FalseColor(imgMasia,'log',1,-1,3,'Masia LDR image in false color');

disp('4) Save the expanded image into a .pfm:');
hdrimwrite(imgMasia,'Venice01_expanded_Masia.pfm'); 
