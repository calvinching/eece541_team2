function newLight=CreateLight(xMin,xMax,yMin,yMax,L,img)
%
%
%        newLight=CreateLight(xMin,xMax,yMin,yMax,L,img)
%
%
%        Input:
%           -(xMin,xMax,yMin,yMax): the bounding box of a region in img
%           -L: the luminance channel of img
%           -img: the full size image
%
%        Output:
%           -newLight: a directional light
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

%Color
tot  = (yMax-yMin+1)*(xMax-xMin+1);
tmpL = L(yMin:yMax,xMin:xMax);
totL = sum(tmpL(:));

if((tot>0)&(totL>0))
    %Color value
    col = reshape(img(yMin:yMax,xMin:xMax,:),tot,1,size(img,3));
    value = sum(col,1);
    
    %Position
    [X,Y] = meshgrid(xMin:xMax,yMin:yMax);
    
    x_light = tmpL.*X;
    x_light = sum(x_light(:))/totL;
    
    y_light = tmpL.*Y;
    y_light = sum(y_light(:))/totL;
  
    [r,c] = size(L);
    
    newLight = struct('color',value,'x',x_light/c,'y',y_light/r);
else
    newLight = [];   
end

end