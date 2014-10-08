function imgOut=LogarithmicTMO(img, q_logarithmic, k_logarithmic)
%
%        imgOut=LogarithmicTMO(img,Log_scale)   
%
%       Author: Francesco Banterle
%       Copyright 2006 (c)
%
%       Input:
%           -img: input HDR image
%           -q_logarithmic: appearance value (1,+inf)
%           -k_logarithmic: appearance value (1,+inf)
%
%       Output
%           -imgOut: tone mapped image
% 
%     Copyright (C) 2010 Francesco Banterle
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

%Is it a three color channels image?
check13Color(img);

if(~exist('q_logarithmic','var'))
    q_logarithmic = 1;
end

if(~exist('k_logarithmic','var'))
    k_logarithmic = 1;
end

%check for q_logarithmic>=1
if(q_logarithmic<1)
    q_logarithmic = 1;
end

%check for q_logarithmic>=1
if(k_logarithmic<1)
    k_logarithmic = 1;
end

%Luminance channel
L = lum(img);

%Maximum luminance value
LMax = max(L(:));

%Dynamic Range Reduction
Ld=log10(1+L*q_logarithmic)/log10(1+LMax*k_logarithmic);

%Changing luminance
imgOut = ChangeLuminance(img, L, Ld);
end