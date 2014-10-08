function img = tabledFunction(img, table)
%
%
%        img = tabledFunction(img, table)
%
%
%        Input:
%           -img: an LDR image with values in [0,255]
%           -table: three functions for remapping image pixels values
%
%        Output:
%           -img: an LDR image with remapped values
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

col = size(img,3);

img = img + 1;

for i=1:col
    work = zeros(size(img(:,:,i)));
    
    values = unique(img(:,:,i));
    n = length(values);
    
    for j=1:n
        k = values(j);
        indx = find(img(:,:,i)==k);
        
        if(isempty(indx)==0)
            work(indx) = table(k,i);
        end
    end
    
    img(:,:,i) = work;
end

end