function imgOut = AkyuzEO(img, Akyuz_Max, Akyuz_gamma, gammaRemoval)
%
%       imgOut = Akyuz(img, Akyuz_Max, Akyuz_gamma, gammaRemoval)
%
%
%        Input:
%           -img: input LDR image with values in [0,1]
%           -Akyuz_Max: the maximum output luminance value defines the 
%           -Akyuz_gamma: this value defines the appearance
%           -gammaRemoval: the gamma value to be removed if known
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

if(~exist('Akyuz_Max','var'))
    Akyuz_Max = 3000;
end

if(~exist('Akyuz_gamma','var'))
    Akyuz_gamma = 1.0;
end

if(~exist('gammaRemoval','var'))
    gammaRemoval=-1;
end

if(gammaRemoval>0.0)
    img=img.^gammaRemoval;
end

L = lum(img);
L_max = max(L(:));
L_min = min(L(:));

Lexp = Akyuz_Max*(((L-L_min)/(L_max-L_min)).^Akyuz_gamma);

%Removing the old luminance
imgOut = ChangeLuminance(img, L, Lexp);

end
