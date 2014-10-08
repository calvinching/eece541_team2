function imgOut = ReinhardGaussianFilter(img, s, alpha_i)
%
%
%      imgOut = ReinhardGaussianFilter(img, s, alpha_i)
%
%
%      Input:
%          -img: an image to be filtered
%          -s: size of the filter in pixel
%          -alpha_i: 
%
%      Output:
%          -imgOut: the filtered image
% 
%     Copyright (C) 2010 Francesco Banterle
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

%Kernel of the filter
s2 = s*5;
[X,Y] = meshgrid(-s2:s2, -s2:s2);
alphaS2 = (alpha_i*s)^2;
H = exp(-(X.^2+Y.^2)/alphaS2)/(pi*alphaS2);
%Filtering
imgOut = imfilter(img,H,'replicate');

end