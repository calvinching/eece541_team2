function imgOut = WardGlobalTMO(img, Ld_Max)
%
%       imgOut = Ward1TMO(img,Ld_Max)
%
%
%       Input:
%           -img: input HDR image
%           -Ld_Max: Maximum LDR luminance
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

if(~exist('Ld_Max'))
    Ld_Max = 100;
end

if(Ld_Max<0)
    Ld_Max = 100;
end

%Luminance channel
L = lum(img);

%harmonic mean
Lwa = logMean(L);

%contrast scale
m = (((1.219+(Ld_Max/2)^0.4)/(1.219+Lwa^0.4))^2.5);

imgOut = (img*m);
imgOut = RemoveSpecials(imgOut / Ld_Max); %Just to have values in [0,1]

end