function img = ldrimread(filename)
%
%       img = ldrimread(filename)
%
%
%        Input:
%           -filename: the name of the file to open
%
%        Output:
%           -img: the opened image
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

if(~exist('filename', 'var'))
    error('A filename with extension needs to be passed as input!');
end

img = [];

try    
    image_info = imfinfo(filename);
    
    if((image_info.BitDepth==24)||(image_info.BitDepth==8))
        img = double(imread(filename))/255;
    end
        
    if(image_info.BitDepth==48)
        img = double(imread(filename))/65535;
    end
    
catch err
    disp(['Error in reading ',filename]);
end

end