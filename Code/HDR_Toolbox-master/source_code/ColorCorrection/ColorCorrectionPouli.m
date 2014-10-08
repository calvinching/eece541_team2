function imgTMO_c = ColorCorrectionPouli(imgHDR, imgTMO)
%
%       imgTMO_c = ColorCorrection(imgHDR, imgTMO)
%
%       This function saturates/desaturates colors in an imgTMO
%
%       input:
%         - imgHDR: a HDR image
%         - imgTMO: a tone mapped version of imgHDR in linear RGB color
%         space
%
%       output:
%         - imgTMO_c: imgTMO with color correction
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
%     The paper describing this technique is:
%     "Color Correction for Tone Reproduction"
% 	  by Tania Pouli1, Alessandro Artusi, Francesco Banterle, 
%     Ahmet Oguz Akyuz, Hans-Peter Seidel and Erik Reinhard
%     in the Twenty-first Color and Imaging Conference (CIC21), Albuquerque, Nov. 2013 
%
%

%is it a three color channels image?
[r1,c1,col1] = size(imgHDR);
[r2,c2,col2] = size(imgTMO);

if((r1~=r2)||(c1~=c2)||(col1~=col2))
    error('imgHDR and imgTMO have different size!');
end

check3Color(imgHDR);

%Normalization step
imgHDR = imgHDR/max(imgHDR(:));
imgTMO = imgTMO/max(imgTMO(:));

%Conversion in the XYZ color space
imgTMO_XYZ = ConvertRGBtoXYZ(imgTMO, 0);
imgHDR_XYZ = ConvertRGBtoXYZ(imgHDR, 0);

%Conversion in the IPT color space
imgTMO_IPT = ConvertXYZtoIPT(imgTMO_XYZ, 0);
imgHDR_IPT = ConvertXYZtoIPT(imgHDR_XYZ, 0);

%ICh color space
C_TMO = sqrt(imgTMO_IPT(:,:,2).^2+imgTMO_IPT(:,:,3).^2);
C_HDR = sqrt(imgHDR_IPT(:,:,2).^2+imgHDR_IPT(:,:,3).^2);

%h_TMO = atan2(imgTMO_IPT(:,:,2)./imgTMO_IPT(:,:,3));
h_HDR = atan2(imgHDR_IPT(:,:,2),imgHDR_IPT(:,:,3));

%Algorithm
C_TMO_prime = C_TMO.*imgHDR_IPT(:,:,1)./imgTMO_IPT(:,:,1);
r = SaturationPouli(C_HDR, imgHDR_IPT(:,:,1))./SaturationPouli(C_TMO_prime, imgTMO_IPT(:,:,1));
C_c = r.*C_TMO_prime;%Final scale

imgTMO_c_IPT = zeros(size(imgTMO));
imgTMO_c_IPT(:,:,1) = imgTMO_IPT(:,:,1);
imgTMO_c_IPT(:,:,2) = sin(h_HDR).*C_c;%Same Hue of imgHDR
imgTMO_c_IPT(:,:,3) = cos(h_HDR).*C_c;%Same Hue of imgHDR

%Conversion back
imgTMO_c_XYZ = ConvertXYZtoIPT(imgTMO_c_IPT, 1);
imgTMO_c = ConvertRGBtoXYZ(imgTMO_c_XYZ, 1);
end