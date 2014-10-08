function imgRec=JPEGHDRDec(name)
%
%
%       imgRec=JPEGHDRDec(name)
%
%
%       Input:
%           -name: the prefix of the compressed HDR images using JPEG HDR
%
%       Output:
%           -imgRec: the reconstructed HDR image
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
gamma = 2.2;

nameOut = RemoveExt(name);
nameRatio = [nameOut,'_ratio.jpg'];

%Read metadata
info = imfinfo(name);
decoded = sscanf(cell2mat(info.Comment), '%g', 3);
maxTMO = decoded(1);

info_ratio = imfinfo(nameRatio);
decoded_ratio = sscanf(cell2mat(info_ratio.Comment), '%g %g', 3);
maxRIenc = decoded_ratio(1);
minRIenc = decoded_ratio(2);
    
%Read the tone mapped layer
imgTMO = maxTMO*((double(imread(name))/255).^gamma);
[r,c,col] = size(imgTMO);

%Read the RI layer
imgRI = (double(imread(nameRatio))/255).^gamma;
imgRI = imgRI*(maxRIenc-minRIenc)+minRIenc;
imgRI = ClampImg(imgRI*32-16,-16,16);
imgRI = 2.^imgRI;
imgRI = imresize(imgRI,[r,c],'bilinear');

%Decoded image
imgRec = zeros(size(imgTMO));
for i=1:3
    imgRec(:,:,i)=imgTMO(:,:,i).*imgRI;
end

imgRec = RemoveSpecials(imgRec);

end