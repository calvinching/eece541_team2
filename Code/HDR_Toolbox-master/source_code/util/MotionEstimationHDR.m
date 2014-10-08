function motionMap = MotionEstimationHDR(img1, img2, blockSize)
%
%        motionMap = MotionEstimationHDR(img1, img2, blockSize)
%
%       This computes motion estimation between HDR frames
%
%       input:
%         - img1: source
%         - img2: target
%         - blockSize: size of the block
%
%       output:
%         - motionMap: motion map for each pixel
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

img1 = lum(img1);
img2 = lum(img2);

[r,c] = size(img1);

if(~exist('blockSize','var'))
    nPixels = r*c;
    blockSize = max([2^ceil(log10(nPixels)),4]);
end


motionMap = MotionEstimation(log(img1+1), log(img2+1), blockSize);

end