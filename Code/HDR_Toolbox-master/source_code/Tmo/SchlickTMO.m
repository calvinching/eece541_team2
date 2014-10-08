function imgOut=SchlickTMO(img, schlick_mode, schlick_p, schlick_bit, schlick_dL0, schlick_k)
%
%       imgOut=SchlickTMO(img, schlick_mode, schlick_p, schlick_bit,schlick_dL0)
%
%
%       Input:
%           -img: input HDR image
%           -schlick_p: in [1,+inf]
%           -schlick_bit: number of bit for the quantization
%           -schlick_dL0: 
%           -schlick_k: in [0,1]
%           -Mode = { 'standard', 'calib', 'nonuniform' }
%
%       Output
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

check13Color(img);

if(~exist('schlick_mode','var'))
    schlick_mode = 'nonuniform';
end

if(~exist('schlick_bit','var'))
    schlick_bit = 8;
end

if(~exist('schlick_dL0','var'))
    schlick_dL0 = 1;
end

if(~exist('schlick_k','var'))
    schlick_k = 0.5;
end

if(~exist('schlick_p','var'))
    schlick_p=1/0.005;
end

%Luminance channel
L = lum(img);

%Max Luminance value 
LMax = max(L(:));

%Min Luminance value 
LMin = min(L(:));
if(LMin<=0.0)
     LMin=min(min(L(LMin>0.0)));
end

%Mode selection
switch schlick_mode
    case 'standard'
        p = schlick_p;        
        if(p<1)
            p=1;
        end
        
    case 'calib'
        p = schlick_dL0*LMax/(2^schlick_bit*LMin);
        
    case 'nonuniform'
        p = schlick_dL0*LMax/(2^schlick_bit*LMin);
        p = p*(1-schlick_k+schlick_k*L/sqrt(LMax*LMin));
end

%Dynamic Range Reduction
Ld=p.*L./((p-1).*L+LMax);

%Changing luminance
imgOut = ChangeLuminance(img, L, Ld);

end