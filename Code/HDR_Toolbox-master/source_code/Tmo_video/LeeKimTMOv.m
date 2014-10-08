function LeeKimTMOv(hdrv, filenameOutput, fBeta, fLambda, fSaturation, tmo_gamma, tmo_quality, tmo_video_profile)
%
%       LeeKimTMOv(hdrv, filenameOutput, fBeta, fLambda, fSaturation, tmo_gamma, tmo_quality, tmo_video_profile)
%
%       This function is a tone mapping operator for videos using the Lee
%       and Kim operator. This is a temporal version of the Fattal and
%       Lischinski gradient domain operator.
%
%       Input:
%           -hdrv: an HDR video structure; use hdrvread to create an hdrv
%           structure
%           -filenameOutput: output filename (if it has an image extension,
%           single files will be generated)
%           -fBeta: coefficient from the paper by Fattal and Lischinski  (Equation 3a, 3b, and 3c)
%           -fSaturaion: a value (0,1] for reducing the saturation in the
%           tonemapped image
%           -tmo_gamma: gamma for encoding the frame
%           -tmo_quality: the output quality in [1,100]. 100 is the best quality
%           1 is the lowest quality.%
%           -tmo_video_profile: the compression profile (encoder) for compressing the stream.
%           Please have a look to the profile of VideoWriter from the MATLAB
%           help. Depending on the version of MATLAB some profiles may be not
%           be present.
% 
%     Copyright (C) 2013-14 Francesco Banterle
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

if(~exist('fBeta','var'))
    fBeta = 0.92;
end

if(~exist('fLambda','var'))
    fLambda = 0.3;
end

if(~exist('fSaturation','var'))
    fSaturation = 0.6;
end

fSaturation = ClampImg(fSaturation, 1e-3 , 1);

if(~exist('tmo_gamma','var'))
    tmo_gamma = 2.2;
end

if(tmo_gamma<0)
    bsRGB = 1;
else
    bsRGB = 0;
end

if(~exist('tmo_quality','var'))
    tmo_quality = 95;
end

if(~exist('tmo_video_profile','var'))
    tmo_video_profile = 'Motion JPEG AVI';
end

name = RemoveExt(filenameOutput);
ext  = fileExtension(filenameOutput);

bVideo = 0;
writerObj = 0;

if(strfind(ext,'avi')|strfind(ext,'mp4'))
    bVideo = 1;
    writerObj = VideoWriter(filenameOutput, tmo_video_profile);
    writerObj.FrameRate = hdrv.FrameRate;
    writerObj.Quality = tmo_quality;
    open(writerObj);
end

hdrv = hdrvopen(hdrv);

disp('Tone Mapping...');

for i=1:hdrv.totalFrames
    disp(['Processing frame ',num2str(i)]);
    [frame, hdrv] = hdrvGetFrame(hdrv, i);

    %Only physical values
    frame = RemoveSpecials(frame);
    frame(frame<0) = 0;   
    
    if(i==1)%Note: normalization has to be taken off
        frameOut = FattalTMO(frame, fBeta, 0);
    else
        %Computing optical flow between frame and framePrev
        offset_map = MotionEstimationHDR(framePrev, frame);
        %Warping
        imgWarped = imWarp(frameOutPrev, offset_map, 0);
        frameOut = LeeKimTMOv_frame(frame, imgWarped, fBeta, fLambda); 
    end
    
    frameOutPrev = frameOut;        
    framePrev = frame;
    
    %Color correction
    frameOut = ColorCorrection(frameOut, fSaturation);
    frameOut = frameOut/MaxQuart(frameOut, 0.99995);
    
    %Gamma/sRGB encoding
    if(bsRGB)
        frameOut = ClampImg(ConvertRGBtosRGB(frameOut, 0), 0, 1);
    else
        frameOut = ClampImg(GammaTMO(frameOut, tmo_gamma, 0, 0), 0, 1);
    end
    
    if(bVideo)
        writeVideo(writerObj,frameOut);
    else
        imwrite(frameOut,[name,sprintf('%.10d',i),'.',ext]);
    end    
end

disp('OK');

if(bVideo)
    close(writerObj);
end

hdrvclose(hdrv);

end
