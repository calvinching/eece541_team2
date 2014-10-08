function LeeKimHDRvEnc(hdrv, name, bCrossBilateralFilter, hdrv_profile, hdrv_quality)
%
%
%       LeeKimHDRvEnc(hdrv, name, bCrossBilateralFilter, hdrv_profile, hdrv_quality)
%
%
%       Input:
%           -hdrv: a HDR video stream, use hdrvread for opening a stream
%           -name: this is the output name of the stream. For example,
%           'video_hdr.avi' or 'video_hdr.mp4'
%           -bCrossBilateralFilter: if it is set to 1 the cross bilateral
%           filtering is used to remove noise from the residuals
%           -hdrv_profile: the compression profile (encoder) for compressing the stream.
%           Please have a look to the profile of VideoWriter from the MATLAB
%           help. Depending on the version of MATLAB some profiles may be not
%           be present.
%           -hdrv_quality: the output quality in [1,100]. 100 is the best quality
%           1 is the lowest quality.
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
% 	  by Chul Lee and Chang-Su Kim
%     in 16th European Signal Processing Conference (EUSIPCO 2008),
%     Lausanne, Switzerland, August 25-29, 2008, copyright by EURASIP
%
%

if(~exist('hdrv_quality','var'))
    hdrv_quality = 95;
end

if(hdrv_quality<1)
    hdrv_quality = 95;
end

if(~exist('bCrossBilateralFilter','var'))
    bCrossBilateralFilter = 0;
end

if(~exist('hdrv_profile','var'))
    hdrv_profile = 'Motion JPEG AVI';
end

if(strcmp(hdrv_profile,'MPEG-4')==0)
    disp('Note that the H.264 profile needs to be used for fair comparisons!');
end

nameOut = RemoveExt(name);
fileExt = fileExtension(name);
nameTMO = [nameOut,'_LK08_tmo.',fileExt];
nameResiduals = [nameOut,'_LK08_residuals.',fileExt];

%Opening hdr stream
hdrv = hdrvopen(hdrv);

%Lee and Kim TMO
tmo_gamma = 2.2;    %as in the original paper
fSaturation = 0.6;  %as in the original paper
fBeta = 0.92;       %as in the original paper
fLambda = 0.3;      %as in the original paper

LeeKimTMOv(hdrv, nameTMO, fBeta, fLambda, fSaturation, tmo_gamma, hdrv_quality, hdrv_profile);

%video Residuals pass
readerObj = VideoReader(nameTMO);

writerObj_residuals = VideoWriter(nameResiduals, hdrv_profile);
writerObj_residuals.Quality = ClampImg(round(LeeKimQuality(hdrv_quality)),1,100);
open(writerObj_residuals);

epsilon = 0.05;%as in the original paper
r_min = zeros(1,hdrv.totalFrames);
r_max = zeros(1,hdrv.totalFrames);

for i=1:hdrv.totalFrames
    disp(['Processing frame ',num2str(i)]);
    
    %HDR frame
    [frame, hdrv] = hdrvGetFrame(hdrv, i);
    h = lum(frame);
    
    %Tone mapped frame
    frameTMO = double(read(readerObj, i))/255;
    frameTMO = GammaTMO(frameTMO,1.0/tmo_gamma,0.0,0);
    frameTMO = ColorCorrection(frameTMO, 1.0/fSaturation);
 
    %Residuals
    l = lum(frameTMO);
    r = RemoveSpecials(log(h./(l+epsilon)));%equation 4 of the original paper
    
    %Normalize in [0,1]
    r_min(i) = min(r(:));
    r_max(i) = max(r(:));    
    r = (r-r_min(i))/(r_max(i)-r_min(i));
    
    %Residuals cross bilateral filtering
    if(bCrossBilateralFilter)
        r = bilateralFilter(r, h, min(h(:)), max(h(:)), 8.0, 0.1 ); %as in the original paper
    end
        
    %writing residuals
    writeVideo(writerObj_residuals, r);
end

close(writerObj_residuals);

save([nameOut,'_LK08_Rinfo.mat'], 'r_min','r_max');

hdrvclose(hdrv);

end
