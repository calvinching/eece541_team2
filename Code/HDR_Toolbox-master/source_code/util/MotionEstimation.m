function motionMap = MotionEstimation(img1, img2, blockSize)
%
%       motionMap = MotionEstimation(img1, img2, blockSize)
%
%       This computes motion estimation between frames
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

[r,c,col] = size(img1);

if(~exist('blockSize','var'))
    nPixels = r*c;
    blockSize = max([2^ceil(log10(nPixels)),4]);
end

maxSearchRadius = 1;%size in blocks

shift = blockSize*maxSearchRadius;

block_r = ceil(r/blockSize);
block_c = ceil(c/blockSize);

motionMap = zeros(r,c,3);

for i=1:block_r   
    for j=1:block_c     
        dx = 0;
        dy = 0;
        err = 1e30;
        
        i_b = (i-1)*blockSize+1;
        j_b = (j-1)*blockSize+1;
        i_e = min([i_b+blockSize-1,r]);
        j_e = min([j_b+blockSize-1,c]);
        
        block1 = zeros(blockSize, blockSize, col);
        block1(1:length(i_b:i_e),1:length(j_b:j_e),:) = img1(i_b:i_e, j_b:j_e, :);
        
        for k=(-shift):shift
            for l=(-shift):shift
                i_b2 = i_b+k;
                j_b2 = j_b+l;
                i_e2 = i_e+k;
                j_e2 = j_e+l;
                  
                if((i_b2>0)&&(j_b2>0)&&(i_e2<=r)&&(j_e2<=c))
                    block2 = zeros(blockSize, blockSize, col);   
                    block2(1:length(i_b2:i_e2),1:length(j_b2:j_e2),:) = img2(i_b2:i_e2, j_b2:j_e2, :);

                    tmp_err = abs(block1-block2);
                    tmp_err = sum(tmp_err(:));

                    if(tmp_err<err)
                        err = tmp_err;
                        dx = l;
                        dy = k;
                    end
                end
            end
        end
                        
        motionMap(i_b:i_e,j_b:j_e,1) =  dx;
        motionMap(i_b:i_e,j_b:j_e,2) =  dy;
        motionMap(i_b:i_e,j_b:j_e,3) =  err;
    end
end

end