function imgOut = HuoPhysEO(img, hou_max_luminance, hou_n, gammaRemoval)
%
%       imgOut = HuoPhysEO(img, hou_max_luminance, hou_n, gammaRemoval)
%
%
%        Input:
%           -img: input LDR image normalized in [0,1]
%           -hou_max_luminance: maximum output luminance in cd/m^2
%           -hou_n: a value which determines the dynamic range percentage
%            of the expanded image allocated to the high luminance level 
%            and low luminance level of the LDR image.
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
%     The paper describing this technique is:
%     "Physiological inverse tone mapping based on retina response"
% 	  by Yongqing HUO, Fan YANG, Le DONG, Vincent BROST 
%     in The Visual Computer September (2013)
%

%is it a three color channels image?
check13Color(img);

if(~exist('gammaRemoval','var'))
    gammaRemoval = -1.0;
end

if(~exist('hou_max_luminance','var'))
    hou_max_luminance = 3000.0;%as in the original paper
end

if(~exist('hou_n','var'))
    hou_n = 0.86;%as in the original paper
end

if(gammaRemoval>0.0)
    img = img.^gammaRemoval;
end

%Computing luminance
L_l = lum(img);
max_L_l = max(L_l(:));
sigma_l = logMean(L_l);

%iterative bilateral filter: 2 passes as in the original paper
L_s_l_1 = bilateralFilter(L_l  ,   [], 0.0, 1.0, 16.0, 0.3);
L_s_l   = bilateralFilter(L_s_l_1, [], 0.0, 1.0, 10.0, 0.1);

%Computing parameters
sigma = hou_max_luminance*sigma_l;
L_s_h = hou_max_luminance*L_s_l;

%Expanding luminance
L_h = ((L_l/max_L_l).*((L_s_h.^hou_n+sigma^hou_n)).^(1.0/hou_n));

%Generate the final image with the new luminance
imgOut = ChangeLuminance(img, L_l, L_h);

end