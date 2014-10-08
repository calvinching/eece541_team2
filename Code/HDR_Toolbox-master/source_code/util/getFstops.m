function [eMin, eMax] = getFstops(img)
%
%
%        [eMin, eMax] = getFstops(img)
%
%
%        Input:
%           -img: the input image
%
%        Output:
%           -eMin: the minimum f-stop
%           -eMax: the maximum f-stop
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

L = lum(img);

maxL = MaxQuart(L,0.999);
minL = MaxQuart(L,0.001);

eMin = round(log2(minL+1e-6));
eMax = round(log2(maxL+1e-6));

end