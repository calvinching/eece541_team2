function expand_map = BanterleExpandMap(img, BEM_bColorRec, BEM_clamping_threshold, BEM_percent, BEM_density_estimation_kernel, BEM_bHighQuality)
%
%		 expand_map = BanterleExpandMap(img, BEM_bColorRec, BEM_clamping_threshold, BEM_percent, BEM_density_estimation_kernel, BEM_bHighQuality)
%
%
%		 Input:
%			-img: an input image LDR image in the linear domain
%           -BEM_bColorRec: a boolean value. If it is set 1 the expand
%           map will be calculated for each color channel
%           -BEM_clamping_threshold: if it is greater than 0, this value
%           determines the threshold for clamping light sources. Otherwise
%           this parameter is estimated automatically.
%           -BEM_percent: values in (0,1]
%           -BEM_density_estimation_kernel: a string representing the
%           kernel for density estimation. The function takes the same
%           input of the fspecial.m MATLAB function.
%           The default value is 'gaussian'.
%           -BEM_bHighQuality: a boolean value. If it is set to 1,
%           LischinskiMinimization will be used for better quality. This
%           takes more than using the bilateral filter. You may need MATLAB
%           at 64-bit for running high quality edge transer at HD
%           resolution (1920x1080).
%
%		 Output:
%			-expand_map: the final expand map
%
%     Copyright (C) 2011-13  Francesco Banterle
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

if(~exist('BEM_percent','var'))
    BEM_percent = 0.95;
else
    BEM_percent = ClampImg(BEM_percent,0.01,1.0);
end

if(~exist('BEM_density_estimation_kernel','var'))
    BEM_density_estimation_kernel = 'gaussian';
end

if(~exist('BEM_bHighQuality','var'))
    BEM_bHighQuality = 1;
end

r = size(img, 1);
c = size(img, 2);

%Computing samples with median cut
[splat_pos, splat_power, window] = BanterleExpandMapSamples(img, BEM_bColorRec, BEM_clamping_threshold, BEM_percent);
  
%Density estimation thorugh splatting
window_scale = 8;
scaled_widow = window * window_scale;
H = fspecial(BEM_density_estimation_kernel,scaled_widow,GKSigma(scaled_widow));
[img_density,counter_map] = imSplat(r,c,H,splat_pos,splat_power); 
    
%Filtering the expand map
fcol = size(img_density,3);
expand_map_de = zeros(r,c,fcol);

for i=1:fcol
    img_density(:,:,i)   = img_density(:,:,i)./counter_map;
    expand_map_de(:,:,i) = GaussianFilterWindow(img_density(:,:,i), scaled_widow);
end

clear('img_density');
clear('counter_map');

%Edge transfer
expand_map = BanterleExpandMapEdgeTransfer(expand_map_de, img, BEM_bHighQuality);

%Expand map normalization
max_em = max(expand_map(:));
if(max_em>0.0)
    expand_map = expand_map/max_em;
end

disp('This implementaion of the Banterle et al. 2008 method is not meant for videos but oly images.');
disp('Please contact the author at f_banty@yahoo.it in case parameters are not clear.');
end