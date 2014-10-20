function expand_map = RempelExpandMap(L, gammaRemoval, bVideoFlag, sigma)
%
%	 expand_map = RempelExpandMap(L, gammaRemoval, bVideoFlag, sigma)
%
%
%    Input:
%       -L: a luminance channel
%       -gammaRemoval: the gamma value to be removed if known
%       -bVideoFlag: a flag, true if img is a frame of a video
%       -sigma: Gaussian kernel of ceil(sigma*5) x ceil(sigma*5)
%
%     Output:
%       -expand_map: the final expand map
%
%     Copyright (C) 2011-14 Francesco Banterle
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

if(~exist('gammaRemoval','var'))
    gammaRemoval = -1;
end

if(~exist('sigma','var'))
    sigma = 30; %150x150 Gaussian filter
end


%saturated pixels threshold - (Smooth brightness enhancement) - section 3.2
thresholdImg   = 250/255;		%Images
thresholdVideo = 230/255;		%Videos

if(~exist('bVideoFlag','var'))
    bVideoFlag = 0;
end

if(bVideoFlag)
     threshold = thresholdVideo;
else
     threshold = thresholdImg;
end

if(gammaRemoval>0)
    threshold = threshold.^gammaRemoval;
end

%binary map for saturated pixels
mask = zeros(size(L)); % generate array of all zeros of size(L)
mask(L>threshold) = 1; % Set mask to 1 if L > threshold

%Filtering with a 150x150 Gaussian kernel size
% Blur mask with large kernel of approx Gaussian shape. Exact size of blur
% kernel depends on the display dimensions and anticipated range of viewing
% distance
sbeFil = GaussianFilter(mask,sigma);

%Calculation of the gradients of L using a 5x5 mask to have thick edges
Sy = [ -1 -4  -6 -4 -1;...
       -2 -8 -12 -8 -2;...
        0  0   0  0  0;...
        2  8  12  8  2;...
        1  4   6  4  1];
Sx = Sy';

norm = sum(abs(Sx(:)));

dy = imfilter(L, Sy/norm);
dx = imfilter(L, Sx/norm);

grad = sqrt(dx.^2+dy.^2);         %magnitude of the directional gradient
%threshold for the gradient
tr = 0.05;%this threshold is for gamma = 2.2

if(gammaRemoval<=0)
    tr = tr^(1.0/2.2);
end

%maximum number of iteration for the flood fill
maxIter = max(size(L));
for k=1:maxIter
    %Flood fill
    tmp  = double(bwmorph(mask,'dilate'));   
    tmp  = abs(tmp-mask);
    val1 = sum(mask(:));
    mask((tmp>0.75)&(grad<tr)&(sbeFil>0.001)) = 1;
   
    %ended?
    if((sum(mask(:))-val1)<1)
        disp(k);
        break;
    end  
end

mask = imopen(mask, ones(3));
%Multiply the flood fill mask with the BEF
expand_map = sbeFil.*GaussianFilter(mask, 1);
end
