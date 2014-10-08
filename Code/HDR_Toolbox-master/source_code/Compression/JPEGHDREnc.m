function JPEGHDREnc(img, name, quality)
%
%
%       JPEGHDREnc(img, name, quality)
%
%
%       Input:
%           -img: HDR image
%           -name:  is output name of the image
%           -quality: is JPEG output quality in [0,100]
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

%remove the extension of the file
nameOut = RemoveExt(name);

if(~exist('quality'))
    quality = 95;
end

if(quality<1)
    quality = 95;
end

quality = ClampImg(quality,1,100);

%Tone mapping using Reinhard's operator
gamma = 2.2;
invGamma = 1.0/gamma;
[imgTMO,pAlpha,pWhite] = ReinhardTMO(img);

%Ratio
RI = lum(img)./lum(imgTMO);
[r,c,col]=size(img);

%JPEG Quantization
flag = 1;
scale = 1;
nameRatio=[nameOut,'_ratio.jpg'];
while(flag)
    RItmp = imresize(RI,scale,'bilinear');    
    RIenc = log2(RItmp+2^-16);
    RIenc = (ClampImg(RIenc,-16,16)+16)/32;
    maxRIenc = max(RIenc(:));
    minRIenc = min(RIenc(:));
    RIenc = (RIenc-minRIenc)/(maxRIenc-minRIenc);
    %Ratio images are stored with maximum quality
    metatadata = [num2str(maxRIenc),' ',num2str(minRIenc)];
    imwrite(RIenc.^invGamma,nameRatio,'Quality',100,'Comment',metatadata);
    scale = scale - 0.005;
    %stop?
    valueDir = dir(nameRatio);
    flag = (valueDir.bytes/1024)>64;
end

imgRI = double(imread(nameRatio))/255;
imgRI = imgRI.^gamma;
imgRI = imgRI*(maxRIenc-minRIenc)+minRIenc;
imgRI = ClampImg(imgRI*32-16,-16,16);
imgRI = 2.^imgRI;
imgRI = imresize(imgRI,[r,c],'bilinear');

%Tone mapped image
for i=1:3
    imgTMO(:,:,i) = img(:,:,i)./imgRI;
end
imgTMO=RemoveSpecials(imgTMO);

%Clamping using the 0.999th percentile
maxTMO=MaxQuart(imgTMO,0.999);
imgTMO=ClampImg(imgTMO/maxTMO,0,1);

metatadata = num2str(maxTMO);
imwrite(imgTMO.^invGamma,name,'Quality',quality,'Comment',metatadata);
end


