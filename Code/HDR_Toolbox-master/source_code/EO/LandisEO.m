function imgOut = LandisEO(img, Landis_alpha, Landis_dynRangeStartLum,  Landis_Max_Luminance, gammaRemoval)
%
%       imgOut = LandisEO(img, Landis_alpha, Landis_dynRangeStartLum, Landis_Max_Luminance, gammaRemoval)
%
%
%        Input:
%           -img:  input LDR image with values in [0,1]
%           -Landis_alpha: this value defines the 
%           -Landis_dynRangeStartLum: threshold for applying the iTMO
%           -Landis_Max_Luminance: maximum output luminance
%           -gammaRemoval: the gamma value to be removed if known
%
%        Output:
%           -imgOut: an expanded image
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

%is it a three color channels image?
check3Color(img);

if(~exist('Landis_alpha','var'))
    Landis_alpha = 2.0;   
end

if(~exist('Landis_dynRangeStartLum','var'))
    Landis_dynRangeStartLum = 0.5;
end

if(~exist('Landis_Max_Luminance','var'))
    Landis_Max_Luminance = 3000.0;      
end

if(~exist('gammaRemoval','var'))
    gammaRemoval = -1;
end

%Gamma removal
if(gammaRemoval>0.0)
    img = img.^gammaRemoval;
end

%Luminance channel
L = lum(img);

%Expanding from the mean value
if(Landis_dynRangeStartLum<=0)
    Landis_dynRangeStartLum = mean(L(:));
end

%Finding pixels needed to be expanded
toExpand = find(L>=Landis_dynRangeStartLum);

%Exapnsion using a power function
maxValL = max(L(:)); %generalization in the case of unnormalized data
weights = ((L(toExpand)-dynRangeStartLum)/(maxValL-dynRangeStartLum)).^Landis_alpha;

Lexp = L;
Lexp(toExpand) = L(toExpand).*(1-weights)+Landis_Max_Luminance*L(toExpand).*weights;

%Removing the old luminance
imgOut = ChangeLuminance(img, L, Lexp);

end