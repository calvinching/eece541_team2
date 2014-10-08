function expand_map = KuoExpandMap(L)
%
%		 expand_map = KuoExpandMap(L)
%
%
%		 Input:
%			-L: a luminance channel
%
%		 Output:
%			-expand_map: the final expand map
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

kernelSize = ceil(0.1*max(size(L)));
kernel = ones(kernelSize)/(kernelSize^2);

Lflt = imfilter(L, kernel);
epsilon = max(Lflt(:));

mask = ones(size(L));
mask(L<epsilon) = 0;
mask = double(bwmorph(mask,'erode'));

tmp_expand_map = L.*mask;

expand_map = bilateralFilter(tmp_expand_map, L);

end