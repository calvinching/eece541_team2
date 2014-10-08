function [imgOut, BTMO_segments] = BanterleTMO(img, BTMO_segments)
%
%
%        [imgOut, BTMO_segments] = BanterleTMO(img, BTMO_segments)
%
%
%       Input:
%           -img: an HDR image with calibrated data in cd/m^2.
%           Note that this algorithm was tested with values
%           from 0.015cd/m^2 to 3,000 cd/m^2
%           -BTMO_segments: a segmented image, each value in a segment is a
%           dynamic range zone; i.e. integer values in [-6,9]. If it is not
%           provided this will be computed with the function CreateSegments
%
%       Output:
%           -imgOut: the tone mapped image using the HybridTMO
%           -BTMO_segments: output the segmentation; the input image is
%           segmented into different zones of dynamic range
% 
%       This TMO is an hybrid operator which merges different
%       Tone Mapping Operators: DragoTMO and ReinhardTMO
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
%     The paper describing this technique is:
%     "Dynamic Range Compression by Differential Zone Mapping Based on 
%     Psychophysical Experiments"
% 	  by Francesco Banterle, Alessandro Artusi, Elena Sikudova, 
%     Thomas Edward William Bashford-Rogers, Patrick Ledda, Marina Bloj, Alan Chalmers 
%     in ACM Symposium on Applied Perception (SAP) - August 2012 
%
%

%Segmentation
if(~exist('BTMO_segments','var'))
    BTMO_segments = CreateSegments(img);
else    
    BTMO_segments = round(BTMO_segments);
end

%TMO look-up table for determing the best
%TMO depending on the luminance zone. These
%values were extracted from a psychophysical
%experiment.
% 0 ---> Drago et al. 2003
% 1 ---> Reinhard et al. 2002
LumZone     = [-2, -1, 0, 1, 2, 3, 4];
TMOForZone =  [ 0,  0, 1, 0, 1, 0, 0];

%Tone mapping
img_dra_tmo = DragoTMO(img);
img_rei_tmo = ReinhardBilTMO(img);

%mask
mask = zeros(size(BTMO_segments));

for i=1:length(LumZone)
    mask(BTMO_segments==LumZone(i)) = TMOForZone(i);
end

%Check if only DragoTMO is used
indx0 = find(mask==1);
if(isempty(indx0))
    imgOut = img_dra_tmo;
    disp('The HybridTMO is using only the Drago TMO only');
end

%Check if only ReinhardBilTMO is used
indx1 = find(mask==0);
if(isempty(indx1))
    imgOut = img_rei_tmo;
    disp('The HybridTMO is using Reinhard TMO only');
end

if(~isempty(indx0)&&~isempty(indx1))%pyramid blending in gamma space
    gamma = 2.2;
    invGamma = 1.0/gamma;
    imgA   = img_rei_tmo.^invGamma;
    imgB   = img_dra_tmo.^invGamma;
    
    imgOut = pyrBlend(imgA,imgB,mask).^gamma;
end

end