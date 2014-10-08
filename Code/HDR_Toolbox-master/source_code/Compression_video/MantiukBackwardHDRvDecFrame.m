function frameHDR = MantiukBackwardHDRvDecFrame(frameTMO, frameR, RF, Q)
%
%
%       frameHDR = MantiukBackwardHDRvDecFrame(frameTMO, frameR, RF, Q)
%
%
%       Input:
%           -frameTMO: a tone mapped frame from the video stream with values in [0,255] at 8-bit
%           -frameR: a residual frame from the residuals stream with values in [0,255] at 8-bit
%           -RF: the reconstruction function for the current frame. This is an array of 256 elements
%           -Q: quantization for the current frame. This is an array of 256 elements
%
%       Output:
%           -frameHDR: the reconstructed HDR frame
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
%     The paper describing this technique is:
%     "Backward Compatible High Dynamic Range MPEG Video Compression"
%           by Rafal Mantiuk, Alexander Efremov, Karol Myszkowski, and Hans-Peter Seidel 
%     in ACM SIGGRAPH 2006
%
%


%Reconstruction of HDR luminance
frameTMO = double(frameTMO);
Ld = round(lum(frameTMO));

Lw_rec = MantiukExpansion(Ld, RF);

%decompression of the residuals
frameR = double(frameR)-127; %values in [-127, 127]
frameR = frameR(:,:,1);
rl = zeros(size(frameR));
for i=1:256
    indx = find(Ld==(i-1));
    if(~isempty(indx))
        rl(indx) = frameR(indx)*Q(i);
    end
end

frame_Y = MantiukLumaCoding(Lw_rec + rl, 1);

%Recovering colors
frameTMO = frameTMO/255.0; %values in [0,1]
frameTMO = ConvertRGBtosRGB(frameTMO, 1); %linear values
Ld = lum(frameTMO);

frameHDR = RemoveSpecials(ChangeLuminance(frameTMO, Ld, frame_Y));

end
