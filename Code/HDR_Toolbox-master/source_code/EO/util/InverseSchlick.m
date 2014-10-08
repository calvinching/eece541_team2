function Lexp = InverseSchlick(img, eo_parameters)
%
%       Lexp = InverseSchlick(img, eo_parameters)
%
%        Input:
%           -img: input LDR image. The image is assumed to be linearized
%           -eo_parameters: is an array of two values:
%               -eo_parameters(1): is the maximum output luminance in cd/m^2
%               -eo_parameters(2): is the minimum output luminance in cd/m^2
%               -eo_parameters(3): 
%
%        Output:
%           -Lexp: expanded luminance using inverse Schlick et al. 1994
%           opeartor
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

%parameters extraction
LMaxOut = eo_parameters(1);
LMinOut = eo_parameters(2);
deltaL0 = eo_parameters(3);

N = 256;

p = (deltaL0*LMaxOut)/(N*LMinOut);

%Luminance channel
L = lum(img);

%Luminance expansion
Lexp = (L*LMaxOut)./(p*(1-L)+L);

end
