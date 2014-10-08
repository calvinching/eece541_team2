%
%       HDR Toolbox demo 4:
%	   1) Load "Venice01.png" LDR image
%      2) Apply Banterle et al. 2008 Expansion Operator
%      3) Show the expanded image in false color
%      4) Save the image as .pfm
%      5) Save the expand map as .pfm
%
%       Author: Francesco Banterle
%       Copyright June 2012 (c)
%
%
disp('1) Load "Venice01.png" LDR image');
img = double(imread('Venice01.png'))/255.0;
h = figure(1);
set(h,'Name','Input LDR image');
imshow(img);

disp('2) Apply Banterle et al. 2008 Expansion Operator:');
disp('   - the image is assumed to be encoded with gamma = 2.2');
disp('   - colored expand map is turned on');
disp('   - manual samples clamping set to 5');
disp('   - Inverse Reinhard et al. 2002 operator is used');
disp('   - High Quality edge-aware filtering is used (LischinskiMinimization.m)');
[imgOut,expand_map] = BanterleEO(img, @InverseReinhard, [2000.0,1000.0], 1, 5, 1, 2.2, 1);

disp('3) Show the expanded image in false color');
FalseColor(imgOut,'log',1,-1,2,'Inverse tone mapped LDR image in false color');

disp('4) Save the expanded image into a .pfm:');
hdrimwrite(imgOut,'Venice01_expanded.pfm');

disp('5) Save the expand map into a .pfm:');
hdrimwrite(expand_map,'Venice01_expand_map.pfm');