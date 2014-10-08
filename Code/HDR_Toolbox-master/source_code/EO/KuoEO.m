function imgOut = KuoEO(img, LMax, LMin, gammaRemoval)
%
%       imgOut = KuoEO(img, LMax, LMin, gammaRemoval)
%
%
%        Input:
%           -img:  input LDR image with values in [0,1]
%           -LMax: maximum luminance output in cd/m^2
%           -LMin: minimum luminance output in cd/m^2
%           -gammaRemoval: the gamma value to be removed if known
%
%        Output:
%           -imgOut: an expanded image
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

%is it a three color channels image?
check13Color(img);

if(~exist('LMax','var'))
    LMax = 3000.0;%The maximum output of a Brightside DR37p
end

if(~exist('LMin','var'))
    LMin = 0.015;  %The minimum output of a Brightside DR37p
end

if(~exist('gammaRemoval','var'))
    gammaRemoval = -1.0;
end

if(gammaRemoval>0.0)
    img=img.^gammaRemoval;
end

%Calculate luminance
L=lum(img);

Lexp = InverseSchlick(img, [LMax,LMin,1]);

expand_map = KuoExpandMap(L);

Lexp = Lexp.*expand_map + (1.0-expand_map).*L;

%Changing luminance
imgOut = ChangeLuminance(img, L, Lexp);

end