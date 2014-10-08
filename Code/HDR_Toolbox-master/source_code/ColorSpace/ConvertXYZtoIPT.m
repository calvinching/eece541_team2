function imgOut = ConvertXYZtoIPT(img, inverse)
%
%       imgOut = ConvertXYZtoIPT(img, inverse)
%
%
%        Input:
%           -img: image to convert from XYZ to IPT or from IPT to XYZ.
%           -inverse: takes as values 0 or 1. If it is set to 1 the
%                     transformation from XYZ to IPT is applied, otherwise
%                     the transformation from IPT to XYZ.
%
%        Output:
%           -imgOut: converted image in XYZ or IPT.
%
%     Copyright (C) 2011  Francesco Banterle
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

%matrix conversion from XYZ to IPT
mtxLMStoIPT = [0.4000 0.4000 0.2000; 4.4550 -4.8510 0.3960; 0.8056 0.3572 -1.1628];

if(inverse==0)
    gamma = 0.43;
    
    imgLMS = ConvertXYZtoLMS(img, 0);
    
    ind0 = find(imgLMS>=0.0);    
    ind1 = find(imgLMS<0.0);
    imgLMS(ind0) = imgLMS(ind0).^gamma;
    imgLMS(ind1) = -(-imgLMS(ind1)).^gamma;
    
    imgOut = ConvertLinearSpace(imgLMS, mtxLMStoIPT);
else
    invGamma = 1.0/0.43;
    
    imgLMS = ConvertLinearSpace(img, inv(mtxLMStoIPT));

    ind0 = find(imgLMS>=0.0);    
    ind1 = find(imgLMS<0.0);
    imgLMS(ind0) = imgLMS(ind0).^invGamma;
    imgLMS(ind1) = -(-imgLMS(ind1)).^invGamma;
    
    imgOut = ConvertXYZtoLMS(imgLMS, 1);
end
            
end
