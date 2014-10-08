function imgOut = ColorCorrectionMantiuk(img, mantiuk_p)
%
%       imgOut = ColorCorrection(img, mantiuk_p)
%
%       This function saturates/desaturates colors in img
%
%       input:
%         - img: an image
%         - mantiuk_p: the saturation correction's factor with values in
%           [0,1]; it can be a gray scale image
%
%       output:
%         - imgOut: corrected values
%
%     Copyright (C) 2013  Francesco Banterle
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
%     The paper describing this technique is:
%     "Color correction in tone mapping"
% 	  by Radoslaw Mantiuk, Rafal Mantiuk, Anna Tomaszewska, Wolfgang Heindrich
%     in Computer Graphics Forum, 2009 (Eurographics 2009)
%
%

%is it a three color channels image?
check3Color(img);

if(~exist('mantiuk_p','var'))
    mantiuk_p = 0.5;
end

mantiuk_p = ClampImg(mantiuk_p, 0.0, 1.0);

L = lum(img);
imgOut = zeros(size(img));
for i=1:size(img,3);
    M = (img(:,:,i)./L);
    Mc = (M-1.0).*mantiuk_p + 1.0;
    imgOut(:,:,i) = Mc.*L;
end

imgOut = RemoveSpecials(imgOut);

end