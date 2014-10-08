function imgOut = imshift(img, is_dx, is_dy)
%
%		 imgOut = imshift(img, is_dx, is_dy)
%
%
%		 Input:
%           -img: an input image to be shifted
%           -is_dx: shift amount (in pixels) on the X-axis
%           -is_dy: shift amount (in pixels) on the Y-axis
%
%		 Output:
%			-imgOut: the final shifted image
%
%     Copyright (C) 2012  Francesco Banterle
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

if(~exist('is_dx', 'var'))
    is_dx = 0;
end

if(~exist('is_dy', 'var'))
    is_dy = 0;
end

imgOut = zeros(size(img));
imgTmp = zeros(size(img));

if(abs(is_dx)>0)
    if(is_dx>0)
        imgTmp(:,(is_dx+1):end,:) = img(:,1:(end-is_dx),:);
    else
        imgTmp(:,1:(end+is_dx),:) = img(:,(1-is_dx):end,:);    
    end
else
    imgTmp = img;
end

if(abs(is_dy)>0)
    
    if(is_dy>0)
        imgOut((is_dy+1):end,:,:) = imgTmp(1:(end-is_dy),:,:);
    else
        imgOut(1:(end+is_dy),:,:) = imgTmp((1-is_dy):end,:,:);    
    end
else
    imgOut = imgTmp;
end

end