function val=MSE(img1, img2)
%
%
%      val = MSE(img1, img2)
%
%
%       Input:
%           -img1: input source image
%           -img2: input target image
%
%       Output:
%           -val: the Mean Squared Error assuming values in [0,1]. Lower
%           values means better quality.
% 
%     Copyright (C) 2006  Francesco Banterle
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

if((CheckSameImage(img1,img2)==0))
    error('The two images are different they can not be used or there are more than one channel.');
end

deltaSquare = (img1-img2).^2;

val = mean(deltaSquare(:));

end
