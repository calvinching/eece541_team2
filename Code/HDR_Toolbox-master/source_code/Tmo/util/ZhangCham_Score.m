function S_i = ZhangCham_Score(theta_stack, i, sigma_s)
%
%
%        S_i = ZhangCham_Score(theta_stack, i, sigma_s)
%
%
%        Input:
%           -theta_stack: a stack of gradient orientations
%           -i: reference exposure
%           -sigma_s: standard deviation of the score
%
%        Output:
%           -S_i: score for the i-th exposure
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

if(~exist('sigma_s'))
    sigma_s = 0.2;
end

sigma_s_2 = (sigma_s.^2)*2;

[r,c,n] = size(theta_stack);

S_i = zeros(r,c);
for j=1:n
    if(j~=i)
        tmp = ZhangCham_ThetaDistance(theta_stack(:,:,i),theta_stack(:,:,j));
        S_i = S_i + exp(-tmp.^2/sigma_s_2);
    end
end

end
