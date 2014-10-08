function alpha = ZhangCham_Alpha(img, zc_tau)
%
%
%        alpha = ZhangCham_ThetaDistance(theta_i, theta_j, window_size)
%
%
%        Input:
%           -img: an LDR image from the stack
%           -zc_tau: threshold for well-exposedness
%
%        Output:
%           -alpha: distance metric
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

if(~exist('zc_tau'))
    zc_tau = 0.9;
end

zc_tau = ClampImg(zc_tau,0.0,1.0);

alpha = zeros(size(img));

alpha( (img>(1-zc_tau))&(img<zc_tau) ) = 1;

end
