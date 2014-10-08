function Lout = MantiukLumaCoding(Lin, inverse)
%
%
%       Lout = MantiukLumaCoding(Lin, inverse)
%
%
%       Input:
%           -Lin: input HDR luminance if inverse = 0 
%                 input HDR Luma otherwise
%           -inverse: if inverse = 1; the function converts from luminance
%           to luma, otherwise the inverse
%
%       Output:
%           -Lout: luma if inverse = 0
%                  luminance otherwise
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

if(inverse==0)
    Lout = zeros(size(Lin));

    Lout( Lin<5.604) = 17.554*Lin(Lin<5.604);
    Lout((Lin>=5.604)&(Lin<10469)) = 826.8*(Lin((Lin>=5.604)&(Lin<10469)).^0.10013)-884.17;
    Lout( Lin>=10469) = 209.16*log(Lin(Lin>=10469))-731.28;
else
    Lout = zeros(size(Lin));

    Lout( Lin<98.381) = 0.056968*Lin(Lin<98.381);
    Lout((Lin>=98.381)&(Lin<1204.7)) = 7.3014e-30*((Lin((Lin>=98.381)&(Lin<1204.7))+884.17).^9.9872);
    Lout( Lin>=1204.7) = 32.994*exp(Lin(Lin>=1204.7)*0.0047811);    
end

end