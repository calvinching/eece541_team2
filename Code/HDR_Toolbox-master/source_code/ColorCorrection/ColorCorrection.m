function imgOut = ColorCorrection(img, schlick_correction)
%
%       imgOut = ColorCorrection(img, schlick_correction)
%
%       This function saturates/desaturates colors in img
%
%       input:
%         - img: an image
%	      - schlick_correction: the saturation correction's factor.
%                       If correction>1 saturation is increased,
%                       otherwise the image is desaturated. This parameter
%                       can be a gray scale image.
%
%       output:
%         - imgOut: corrected values
%
%     Copyright (C) 2011  Francesco Banterle
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

%is it a three color channels image?
check3Color(img);

if(~exist('schlick_correction','var'))
    schlick_correction = 0.5;
end

schlick_correction = ClampImg(schlick_correction,0.0,1.0);

L = lum(img);
imgOut = zeros(size(img));

for i=1:size(img,3);
    imgOut(:,:,i) = ((img(:,:,i)./L).^schlick_correction).*L;
end

imgOut = RemoveSpecials(imgOut);

end