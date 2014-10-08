function d_ij = ZhangCham_ThetaDistance(theta_i, theta_j, window_size)
%
%
%        d_ij = ZhangCham_ThetaDistance(theta_i, theta_j, window_size)
%
%
%        Input:
%           -theta_i: gradient orientation of the i-th exposure 
%           -theta_j: gradient orientation of the j-th exposure 
%           -window_size: size of the kernel for the average
%
%        Output:
%           -d_ij: distance metric
%
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

if(~exist('window_size'))
    window_size = 9;
end

diff = abs(theta_i-theta_j);

window_size_full = window_size*2+1;
kernel = ones(window_size_full)/(window_size_full*window_size_full);

d_ij = imfilter(diff,kernel, 'replicate');

end

