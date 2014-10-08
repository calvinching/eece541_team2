function imgGlare = ComputeGlareImage( img, PSF, hot_pixels_pos)
%
%       imgGlare = ComputeGlareImage( img, PSF )
%
%       This function computes the glare image of an input HDR image given
%       a point spread function (PSF) as a kernel.
%
%        Input:
%           -img: an HDR image
%           -PSF: a point spread function stored as a kernel
%           -hot_pixels_pos: hot pixels' coordinates
%
%        Output:
%           -imgGlare: the estimated glare in img.
%
%     Copyright (C) 2014  Francesco Banterle
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
%

m = size(hot_pixels_pos, 2);

hot_pixels_col = zeros(m, 3);
for i=1:m
    hot_pixels_col(i, :) = img(hot_pixels_pos(2, i), hot_pixels_pos(1, i), :); 
end

[imgGlare, counter_map] = imSplat(size(img, 1), size(img, 2),PSF, hot_pixels_pos, hot_pixels_col);

%compensation
while(1)
    ind = find(imgGlare > img);
       
    if(isempty(ind))
        break
    end
    
    scale = img(ind(1)) / imgGlare(ind(1));
    
    imgGlare = imgGlare * scale;
end 

end