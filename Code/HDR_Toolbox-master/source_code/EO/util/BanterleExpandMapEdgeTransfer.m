function expand_map = BanterleExpandMapEdgeTransfer(expand_map_de, img, BEM_bHighQuality)
%
%		 expand_map = BanterleExpandMapEdgeTransfer(expand_map_de, img, BEM_bHighQuality)
%
%
%		 Input:
%           -expand_map_de: expand map after density estimation; i.e.
%           without strong edges
%			-img: an input image LDR image in the linear domain
%           -BEM_bHighQuality: a boolean value. If it is set to 1,
%           LischinskiMinimization will be used for better quality. This
%           takes more than using the bilateral filter. You may need MATLAB
%           at 64-bit for running high quality edge transer at HD
%           resolution (1920x1080).
%
%		 Output:
%			-expand_map: the final expand map
%
%     Copyright (C) 2011-13  Francesco Banterle
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

if(~exist('BEM_bHighQuality','var'))
    BEM_bHighQuality = 0;
end

%Edge transfer
[r,c,col] = size(expand_map_de);

expand_map = zeros(r,c,col);

switch col
    case 1%Grayscale case
        if(size(img,3) ~= 1)
            img = lum(img);
        end
        
        if(BEM_bHighQuality)
            expand_map = LischinskiMinimization(img, expand_map_de, 0.07*ones(r,c));
        else
            expand_map = bilateralfilter(expand_map_de, img);
        end    
        
    case 3%RGB Colors
        imgLab = ConvertXYZtoCIELab(ConvertRGBtoXYZ(img,0),0);
        expand_map_de_Lab = ConvertXYZtoCIELab(ConvertRGBtoXYZ(expand_map_de,0),0);
        
        for i=1:col
            tmpImg = imgLab(:,:,i);
            minI = min(tmpImg(:));
            maxI = max(tmpImg(:));
            tmpImg = (tmpImg-minI)/(maxI-minI);
           
            tmpEmap = expand_map_de_Lab(:,:,i);
            minE = min(tmpEmap(:));
            maxE = max(tmpEmap(:));
            tmpEmap = (tmpEmap-minE)/(maxE-minE);  
            
            if(BEM_bHighQuality)
                expand_map(:,:,i) = LischinskiMinimization(tmpImg,tmpEmap,0.07*ones(r,c))*(maxE-minE)+minE;
            else
                expand_map(:,:,i) = bilateralFilter(tmpEmap,tmpImg)*(maxE-minE)+minE;                
            end
        end
            
        expand_map = ConvertRGBtoXYZ(ConvertXYZtoCIELab(expand_map,1),1);        
        
    otherwise%2,4 and more colors
        for i=1:col
            if(BEM_bHighQuality)
                expand_map(:,:,i) = LischinskiMinimization(img(:,:,i),expand_map_de(:,:,i),0.07*ones(r,c));
            else
                expand_map(:,:,i) = bilateralFilter(expand_map_de(:,:,i),img(:,:,i));
            end
        end        
end

%Check
expand_map(expand_map<0) = 0;

end