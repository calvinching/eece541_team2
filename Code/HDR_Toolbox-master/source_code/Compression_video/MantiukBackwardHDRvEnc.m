function MantiukBackwardHDRvEnc(hdrv, name, hdrv_profile, hdrv_quality)
%
%
%       MantiukBackwardHDRvEnc(hdrv, name, hdrv_profile, hdrv_quality)
%
%
%       Input:
%           -hdrv: a HDR video stream, use hdrvread for opening a stream
%           -name: this is the output name of the stream. For example,
%           'video_hdr.avi' or 'video_hdr.mp4'
%           -hdrv_profile: the compression profile (encoder) for compressing the stream.
%           Please have a look to the profile of VideoWriter from the MATLAB
%           help. Depending on the version of MATLAB some profiles may be not
%           be present.
%           -hdrv_quality: the output quality in [1,100]. 100 is the best quality
%           1 is the lowest quality.
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
%     "Backward Compatible High Dynamic Range MPEG Video Compression"
% 	  by Rafal Mantiuk, Alexander Efremov, Karol Myszkowski, and Hans-Peter Seidel 
%     in ACM SIGGRAPH 2006
%
%

if(~exist('hdrv_quality','var'))
    hdrv_quality = 95;
end

if(hdrv_quality<1)
    hdrv_quality = 95;
end

if(~exist('hdrv_profile','var'))
    hdrv_profile = 'Motion JPEG AVI';
end

if(strcmp(hdrv_profile,'MPEG-4')==0)
    disp('Note that the H.264 profile needs to be used for fair comparisons!');
end

nameOut = RemoveExt(name);
fileExt = fileExtension(name);
nameTMO = [nameOut,'_MB06_tmo.',fileExt];
nameResiduals = [nameOut,'_MB06_residuals.',fileExt];

%Opening hdr stream
hdrv = hdrvopen(hdrv);

%Opening compression streams
KiserTMOv(hdrv, nameTMO, 0.95, 0, -1, hdrv_quality, hdrv_profile)

%video Residuals pass
readerObj = VideoReader(nameTMO);

writerObj_residuals = VideoWriter(nameResiduals, hdrv_profile);
writerObj_residuals.Quality = hdrv_quality;
open(writerObj_residuals);

RFv = zeros(256,hdrv.totalFrames);
Qv  = zeros(256,hdrv.totalFrames);

for i=1:hdrv.totalFrames
    disp(['Processing frame ',num2str(i)]);
    
    %HDR frame
    [frame, hdrv] = hdrvGetFrame(hdrv, i);
    frame_Y = lum(frame);
    frame_luma = MantiukLumaCoding(frame_Y, 0);
    
    %Tone mapped frame
    frameTMO = double(read(readerObj, i));  
 
    %Residuals
    Ld = round(lum(frameTMO));
    [imgR, RF, Q] = MantiukResidualImage(Ld, frame_luma);
    
    %Residuals filtering    
    writeVideo(writerObj_residuals, (imgR + 127)/255);
    RFv(:,i) = RF;
    Qv(:,i) = Q;
end

close(writerObj_residuals);

save([nameOut,'_MB06_Rinfo.mat'], 'RFv','Qv');

hdrvclose(hdrv);

end
