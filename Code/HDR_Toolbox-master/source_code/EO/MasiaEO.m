function [imgOut,bWarning] = MasiaEO(img, Masia_Max, Masia_noise_removal, gammaRemoval)
%
%       [imgOut,bWarning] = MasiaEO(img, Mesia_Max, Masia_noise_removal, gammaRemoval)
%
%
%        Input:
%           -img: input LDR image with values in [0,1]
%           -Masia_Max: maximum luminance output in cd/m^2
%           -Masia_noise_removal: if set to 1 it removes noise or artifacts
%           using the bilateral filter
%           -gammaRemoval: the gamma value to be removed if known
%
%        Output:
%           -imgOut: an expanded image
%           -bWarning: a flag if there was gamma inversion
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
check3Color(img);

if(~exist('Masia_Max','var'))
    Masia_Max = 3000.0;%The maximum output of a Brightside DR37p
end

if(~exist('gammaRemoval','var'))
    gammaRemoval = -1.0;
end

if(~exist('Masia_noise_removal','var'))
    Masia_noise_removal = 1;
end

if(gammaRemoval>0.0)
    img=img.^gammaRemoval;
end

bWarning = 0;

%Calculate luminance
L = lum(img);

%Calculate image statistics
Lav  = logMean(L);
maxL = MaxQuart(L,0.99);
minL = MaxQuart(L(L>0),0.01);

imageKey = (log(Lav) - log(minL))/(log(maxL) - log(minL));

%Calculate the gamma correction value
a_var = 10.44;
b_var = -6.282;

gamma_cor = imageKey*a_var + b_var;

if(gamma_cor<=0.0)
    disp('WARNING: gamma_cor value is negative so the image may have false color.');
    bWarning = 1;
end

%Bilateral filter to avoid to boost noise/artifacts
if(Masia_noise_removal)
    Lbase = bilateralFilter(L);
    Ldetail = RemoveSpecials(L./Lbase);
    Lexp = Ldetail.*(Lbase.^gamma_cor);
else
    Lexp = L.^gamma_cor;
end

%Changing luminance
imgOut = ChangeLuminance(img, L, Lexp*Masia_Max);

end