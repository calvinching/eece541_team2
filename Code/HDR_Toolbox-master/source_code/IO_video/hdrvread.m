function hdrv = hdrvread(filename)
%
%        hdrv = hdrvread(filename)
%
%
%        Input:
%           -filename: the name or the folder path of the HDR video to open
%
%        Output:
%           -hdrv: a HDR video structure
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

hdrv = [];

if(isdir(filename))
    tmp_list = dir([filename,'/','*.hdr']);
    type = 'TYPE_HDR_RGBE';
    
    if(isempty(tmp_list))
        tmp_list = dir([filename,'/','*.pfm']);
        type = 'TYPE_HDR_PFM';
    end
    
    if(isempty(tmp_list))%assuming frames compressed with JPEG HDR
        tmp_list = dir([filename,'/','*.jpg']);
        type = 'TYPE_HDR_JPEG';
    end

    if(isempty(tmp_list))%assuming frames compressed with HDR JPEG 2000
        tmp_list = dir([filename,'/','*.jp2']);
        type = 'TYPE_HDR_JPEG_2000';
    end
    
    if(isempty(tmp_list))
        type = 'TYPE_HDR_FAIL';
    end
    
    hdrv = struct('type',type,'path',filename,'list',tmp_list,'totalFrames',length(tmp_list),'FrameRate',30,'frameCounter',1,'streamOpen',0);
else
    nameOut = RemoveExt(filename);
    fileExt = fileExtension(filename);
    
    if(strfind(nameOut,'_MB06_'))%is it a Mantiuk Backward 2006 HDRv stream?
        type = 'TYPE_HDRV_MB06';
        
        pos = strfind(nameOut,'_MB06_');
        name = nameOut(1:(pos-1));        
        streamTMO = VideoReader([name,'_MB06_tmo.',fileExt]);
        streamR   = VideoReader([name,'_MB06_residuals.',fileExt]);
        Rinfo     = load([name,'_MB06_Rinfo.mat']);
        hdrv = struct('type',type,'path',nameOut,'totalFrames',streamTMO.NumberOfFrames,'FrameRate',streamTMO.FrameRate,'frameCounter',1,'streamOpen',0,'streamTMO',streamTMO,'streamR',streamR,'Rinfo',Rinfo);
    end
    
    if(strfind(nameOut,'_LK08_'))%is it a Lee and Kim 2008 HDRv stream?
        type = 'TYPE_HDRV_LK08';

        pos = strfind(nameOut,'_LK08_');
        name = nameOut(1:(pos-1));        
        streamTMO = VideoReader([name,'_LK08_tmo.',fileExt]);
        streamR   = VideoReader([name,'_LK08_residuals.',fileExt]);
        Rinfo     = load([name,'_LK08_Rinfo.mat']);
        hdrv = struct('type',type,'path',nameOut,'totalFrames',streamTMO.NumberOfFrames,'FrameRate',streamTMO.FrameRate,'frameCounter',1,'streamOpen',0,'streamTMO',streamTMO,'streamR',streamR,'Rinfo',Rinfo);
    end        
end

end