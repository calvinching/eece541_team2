function imgRFlt = MantiukResidualsFiltering(img, imgR)
%
%
%        imgOut = MantiukResidualsFiltering(img, imgR)
%
%
%       Input:
%           -img: reference HDR values
%           -imgR: residuals to be filtered using img
%
%       Output:
%           -imgRFlt: residuals, imgR, filtered using img
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

filterType = 'db3';

%Computing DWT2 transform
pyr  = dwt2Decomposition(img,  filterType, 3);
pyrR = dwt2Decomposition(imgR, filterType, 3);

%CSF Scaling
pyr_CSF  = MantiukDWTScaling(pyr);
pyrR_CSF = MantiukDWTScaling(pyrR);

pyrOut = [];

for i=1:3
    %cH
    T_e = MantiukThresholdElevation(pyr_CSF(i).cH);
    cHFlt = pyrR(i).cH;
    cHFlt(T_e<pyrR_CSF(i).cH) = 0;

    %cV
    T_e = MantiukThresholdElevation(pyr_CSF(i).cV);
    cVFlt = pyrR(i).cV;
    cVFlt(T_e<pyrR_CSF(i).cH) = 0;
    
    %cD
    T_e = MantiukThresholdElevation(pyr_CSF(i).cD);
    cDFlt = pyrR(i).cD;
    cDFlt(T_e<pyrR_CSF(i).cD) = 0;
        
    pyrOut = [pyrOut, struct('cA',pyrR(i).cA,'cH',cHFlt,'cV',cVFlt,'cD',cDFlt)];
end

imgRFlt = dwt2Reconstruction(pyrOut, filterType);

end