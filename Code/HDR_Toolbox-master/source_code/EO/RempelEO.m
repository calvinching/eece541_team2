function imgOut = RempelEO(img, gammaRemoval, noiseReduction, bVideoFlag)
%
%		 imgOut = RempelEO(img, gammaRemoval, noiseReduction, bVideoFlag)
%
%
%        Input:
%           -img: input LDR image with values in [0,1]
%           -gammaRemoval: the gamma value to be removed if known
%           -noiseReduction: a boolean flag for activating the noise
%           reduction
%           -bVideoFlag: a flag, true if img is a frame of a video
%
%        Output:
%           -imgOut: an expanded image
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
check13Color(img);

if(~exist('gammaRemoval','var'))
    gammaRemoval = -1;
end
    
if(~exist('noiseReduction','var'))
    noiseReduction = 0;
end

if(~exist('bVideoFlag','var'))
    bVideoFlag = 0;
end

%Gamma removal
if(gammaRemoval>0.0)
    img  = img.^gammaRemoval;
end

%noise reduction using a gentle bilateral filter of size 4 pixels
%(which is equal to sigma_s=0.8 sigma_r=0.05)
if(noiseReduction)
    for i=1:3
        img(:,:,i) = bilateralFilter(img(:,:,i),[],min(min(img(:,:,i))),max(max(img(:,:,i))),0.8,0.05);
    end
end

%Luminance channel
L = lum(img);

%Luminance expansion
white_level = 1200.0; %White Levels 1200 Cd/m^2
black_level = 0.3;    %Black Levels 0.3 Cd/m^2
Lexp = L*(white_level-black_level)+black_level;

%Generate expand map
expand_map = RempelExpandMap(L, gammaRemoval, bVideoFlag);

%Remap expand map range in [1,..., rescale_alpha]
rescale_alpha = 4.0;
expand_map = expand_map*(rescale_alpha-1)+1;

%Final HDR Luminance
Lfinal = expand_map.*Lexp;

%Removing the old luminance
imgOut = zeros(size(img));
for i=1:size(img,3)
    imgOut(:,:,i) = img(:,:,i).*Lfinal;
end

imgOut = RemoveSpecials(imgOut);

end
