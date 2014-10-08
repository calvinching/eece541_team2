function pyr = MantiukDWTScaling(pyr)
%
%
%       pyr = MantiukDWTScaling(pyr)
%
%
%       Input:
%           -pyr: a DWT decomposition
%
%       Output:
%           -pyr: scaled DWT decomposition
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

if(length(pyr)<3)
    error('This DWT decomposition needs to have at least 3 levels!');
end

%coefficients scaling
LH = [0.275783, 0.837755, 0.999994];
HL = [0.275783, 0.837755, 0.999994];
HH = [0.090078, 0.701837, 0.999988];

for i=1:3
    pyr(i).cH = pyr(i).cH * LH(i);
    pyr(i).cV = pyr(i).cV * HL(i);
    pyr(i).cD = pyr(i).cD * HH(i);
end

end