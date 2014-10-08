function Lw_rec = MantiukExpansion(Ld, RF)
%
%       Lw_rec = MantiukExpansion(Ld, RF)
%
%
%       Input:
%           -Ld: Lw tone mapped luminance 8-bit in [0,255]
%           -RF: Mantiuk's reconstruction function
%
%       Output:
%           -Lw_rec: the reconstructed 12-bit luma
%           
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

Lw_rec = zeros(size(Ld));
for i=1:256
    indx = find(Ld==(i-1));

    if(~isempty(indx))
        Lw_rec(indx) = RF(i);
    end
end

end