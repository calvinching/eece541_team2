function PNGHDREnc(img, nameHDR, namePNG)
%
%
%       PNGHDREnc(img, nameHDR, namePNG)
%
%
%       Input:
%           -img:   HDR image
%
%           -nameHDR: is the name of the HDR image if img is empty
%           -namePNG: is the name of the output PNG image
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
if(isempty(img))
    if(exist('nameHDR'))
        img = hdrimread(nameHDR);
    end
end

if(~exist('namePNG'))
    namePNG = [nameHDR(1:(end-4)),'.png'];
end

check3Color(img);

%Gamma Encoding
gamma = 2.0;
invGamma = 1.0/gamma;

%Tone mapping using Reinhard's operator
L = lum(img);
Lwa= logMean(L);
La = L*ReinhardAlpha(L)/Lwa;
Ld = La./(La+1);

imgTMO = zeros(size(img));
for i=1:3
    imgTMO(:,:,i) = ((img(:,:,i)./L).^0.2).*Ld;
end
imgTMO = RemoveSpecials(imgTMO);

%Clamping
maxTMO = MaxQuart(imgTMO, 0.999);
imgTMO = ClampImg(imgTMO/maxTMO,0.0,1.0);

%Ratio
RI = L./Ld;
RI(Ld<=0)=0;
RIenc = ClampImg(log2(RI+2^-16.0), -16.0, 16.0);
RIenc = (RIenc+16.0)/32.0;

imwrite(imgTMO.^invGamma,namePNG,'Alpha',RIenc.^invGamma,'Gamma',invGamma,'Comment',['Created using Banterle PNG-HDR: maxTMO: ',num2str(maxTMO)]);
end