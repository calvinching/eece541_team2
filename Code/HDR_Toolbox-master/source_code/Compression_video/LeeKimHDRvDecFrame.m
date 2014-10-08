function frameHDR = LeeKimHDRvDecFrame(frameTMO, frameR, r_min, r_max)
%
%
%       frameHDR = LeeKimHDRvDecFrame(frameTMO, frameR, r_min, r_max, fSaturation, tmo_gamma)
%
%
%       Input:
%           -frameTMO: a tone mapped frame from the video stream with values in [0,255] at 8-bit
%           -frameR: a residual frame from the residuals stream with values in [0,255] at 8-bit
%           -r_min: the minimum value of frameR
%           -r_max: the maximum value of frameR
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
%     "RATE-DISTORTION OPTIMIZED COMPRESSION OF HIGH DYNAMIC RANGE VIDEOS"
%           by Chul Lee and Chang-Su Kim
%     in 16th European Signal Processing Conference (EUSIPCO 2008),
%     Lausanne, Switzerland, August 25-29, 2008, copyright by EURASIP
%
%

%decompression of the residuals frame
frameR = frameR(:,:,1);
frameR = double(frameR)/255.0;
frameR = frameR*(r_max-r_min) + r_min;

%decompression of the tone mapped frame
tmo_gamma = 2.2;   %as in the original paper
fSaturation = 0.6; %as in the original paper

frameTMO = double(frameTMO)/255.0;
frameTMO = GammaTMO(frameTMO, 1.0/tmo_gamma, 0.0, 0);
frameTMO = ColorCorrection(frameTMO, 1.0/fSaturation);

%expanding luminance
epsilon = 0.05;%as in the original paper
l = lum(frameTMO);
h = exp(frameR).*(l+epsilon);

%adding colors
frameHDR = RemoveSpecials(ChangeLuminance(frameTMO, l, h));

end

