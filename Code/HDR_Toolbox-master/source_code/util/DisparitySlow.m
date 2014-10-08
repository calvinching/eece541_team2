function disparityMap = DisparitySlow(imgL, imgR, dm_patchSize, dm_maxDisparity, dm_metric)
%
%       disparityMap = DisparitySlow(imgL, imgR, dm_patchSize, dm_maxDisparity, dm_metric)
%
%       Computing stereo disparity map
%
%       input:
%         - imgL: left image
%         - imgR: right image
%         - dm_patchSize: size of the patch for comparisons
%         - dm_maxDisparity: maximum disparity
%         - dm_metric: the type of metric for computing disparity: 'SSD' (sum of
%           squared differences), 'SAD' (sum of absolute differences), 'NCC'
%           (normalized cross-correlation)
%
%       output:
%         - offsetMap: shift vectors from img1 to img2
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

if(~exist('dm_patchSize','var'))
    dm_patchSize = 7;
end

if(~exist('dm_maxDisparity','var'))
    dm_maxDisparity = dm_patchSize*4;
end

if(~exist('dm_metric','var'))
    dm_metric = 'SSD';    
end

[r,c,~] = size(imgL);

halfPatchSize = ceil(dm_patchSize/2);

disparityMap = zeros(r,c,2);

for i=(dm_patchSize+1):(r-dm_patchSize-1)
    
    for j=(dm_patchSize+1):(c-dm_patchSize-1)
        
        err = 1e30;
        disp = j;
        patch1 = imgL((i-halfPatchSize):(i+halfPatchSize), (j-halfPatchSize):(j+halfPatchSize), :);
        p1_2 = patch1.^2;
        
        min_j = max([j-dm_maxDisparity,dm_patchSize+1]);
        max_j = min([j+dm_maxDisparity,c-dm_patchSize-1]);
        
        for k=min_j:max_j
            patch2 = imgR((i-halfPatchSize):(i+halfPatchSize), (k-halfPatchSize):(k+halfPatchSize), :);
            p2_2 = patch2.^2;
                
            switch dm_metric
                case 'SSD'
                    tmp_err = (patch1-patch2).^2;
                case 'SAD'
                    tmp_err = abs(patch1-patch2);
                case 'NCC'
                    tmp_err = (patch1.*patch2)/sqrt(sum(p1_2(:))*sum(p2_2(:)));
                otherwise
                    tmp_err = (patch1-patch2).^2;
            end
            
            tmp_err = sum(tmp_err(:));
                
            if(tmp_err<err)
                err = tmp_err;
                disp = k-j;
            end            
        end
        
        disparityMap(i,j,1) =  disp;
        disparityMap(i,j,2) =  err;
    end
end

end