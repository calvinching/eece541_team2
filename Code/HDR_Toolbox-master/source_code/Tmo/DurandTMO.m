function imgOut = DurandTMO(img, Lda, CMax)
%
%       imgOut = DurandTMO(img, Lda, CMax)  
%
%
%        Input:
%           -img: input HDR image
%           -Lda: adaptation luminance in [30,100] cd/m^2
%           -CMax: maximum ldr monitor luminance in [30,100] cd/m^2
%
%        Output:
%           -imgOut: tone mapped image
% 
%     Copyright (C) 2010  Francesco Banterle
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

%default parameters
if(~exist('Lda','var'))
    Lda=80;
end

if(~exist('CMax','var'))
    CMax=100;
end

%Luminance channel
L=lum(img);

col = size(img,3);

%Chroma
for i=1:col
    img(:,:,i) = RemoveSpecials(img(:,:,i)./L);
end

%Fine details and base separation
[Lbase,Ldetail]=BilateralSeparation(L);

%Tumblin-Rushmeier TMO
for i=1:col
    img(:,:,i)=img(:,:,i).*Lbase;
end

imgOut = TumblinRushmeierTMO(img, Lda, CMax);

%Adding details back
for i=1:col
    imgOut(:,:,i) = imgOut(:,:,i).*Ldetail;
end

end