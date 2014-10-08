function BoitardTMOv(hdrv, filenameOutput, tmo_operator, tmo_gamma, tmo_zeta, tmo_quality, tmo_video_profile)
%
%
%       BoitardTMOv(hdrv, filenameOutput, tmo_operator, tmo_gamma, tmo_zeta, tmo_quality, tmo_video_profile)
%
%
%       Input:
%           -hdrv: a HDR video structure; use hdrvread to create a hdrv
%           structure
%           -filenameOutput: output filename (if it has an image extension,
%           single files will be generated)
%           -tmo_operator: the tone mapping operator to use
%           -tmo_gamma: gamma for encoding the frame
%           -tmo_zeta: it is the "Minscale" parameter of the original paper,
%           please see Equation 8 of it.
%           -tmo_quality: the output quality in [1,100]. 100 is the best quality
%           1 is the lowest quality.%
%           -tmo_video_profile: the compression profile (encoder) for compressing the stream.
%           Please have a look to the profile of VideoWriter from the MATLAB
%           help. Depending on the version of MATLAB some profiles may be not
%           be present.
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
%
%     The paper describing this operator is:
%     "Temporal Coherency for Video Tone Mapping"
%     by R. Boitard, K. Bouatouch, R. Cozot, D. Thoreau, A. Gruson
%     Proc. SPIE 8499, Applications of Digital Image Processing XXXV
%
%     DOI: 10.1117/12.929600 
%
%     Link : http://people.irisa.fr/Ronan.Boitard/articles/2012/TCVTM2012.pdf
%

if(~exist('tmo_operator','var'))
    tmo_operator = @ReinhardTMO;
end

if(~exist('tmo_gamma','var'))
    tmo_gamma = 2.2;
end

if(tmo_gamma<0)
    bsRGB = 1;
else
    bsRGB = 0;
end

if(~exist('tmo_zeta','var'))
    tmo_zeta = 0.1;
end

if(~exist('tmo_quality','var'))
    tmo_quality = 95;
end

if(~exist('tmo_video_profile','var'))
    tmo_video_profile = 'Motion JPEG AVI';
end

name = RemoveExt(filenameOutput);
ext = fileExtension(filenameOutput);

[hdrv_hm, hdrv_max, hdrv_min, hdrv_mean] = hdrvAnalysis(hdrv);
save([name,'_tmo_stream_info.dat'],'hdrv_hm','hdrv_max','hdrv_min','hdrv_mean');

[max_log_mean_HDR,index] = max(hdrv_hm);
[frame, hdrv] = hdrvGetFrame(hdrv, index);

frame_tmo = tmo_operator(RemoveSpecials(frame));
max_log_mean_LDR = logMean(lum(frame_tmo));

bVideo = 0;
writerObj = 0;

if(strfind(ext,'avi')||strfind(ext,'mp4'))
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
        
    frameOut = BoitardTMOv_frame(RemoveSpecials(frame), max_log_mean_HDR, max_log_mean_LDR, tmo_operator, tmo_zeta);

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

hdrv = hdrvclose(hdrv);

end
