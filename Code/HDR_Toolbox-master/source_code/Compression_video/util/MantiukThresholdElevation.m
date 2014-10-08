function T_e = MantiukThresholdElevation(img)
%
%
%       T_e = MantiukThresholdElevation(img)
%
%
%       Input:
%           -img: DWT coefficients
%
%       Output:
%           -T_e: threshold elevation function
%
%     Copyright (C) 2013-14  Francesco Banterle
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

n = 13;%as in the original paper
L_CSF = abs(img).^0.2;
L_CSF = imfilter(L_CSF, ones(n)/(n*n),'replicate');
L_CSF = L_CSF.^(1.0/0.2);

%Threshold elevation
a = 0.093071;
b = 1.0299;
c = 11.535;

T_e = ones(size(img));
T_e(L_CSF>a) = c*(L_CSF(L_CSF>a).^b); 

end