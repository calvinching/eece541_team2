function ret = hdrimwrite(img, filename, jpeg_hdr_quality, hdr_jpeg_2000_ratio)
%
%       ret=hdrimwrite(img, filename)
%
%
%        Input:
%           -img: the image to write on the hard disk
%           -filename: the name of the image to write
%           -jpeg_hdr_quality: quality for JPEG-HDR encoder
%           -hdr_jpeg_2000_ratio: ratio for HDR JPEG 2000
%
%        Output:
%           -ret: a boolean value, it is set to 1 if the write succeed, 0 otherwise
%
%     Copyright (C) 2011-2013  Francesco Banterle
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

%if it is a gray image we create three channels
col = size(img,3);

if(isempty(img))
    error('Empty images cannot be written!');
end

if(~exist('filename', 'var'))
    error('A filename with extension needs to be passed as input!');
end

if(col==1)
    [r,c] = size(img);
    imgOut = zeros(r,c,3);
    
    for i=1:3
        imgOut(:,:,i) = img;
    end
    
    img = imgOut;
end

ret = 0;

if(~exist('jpeg_hdr_quality','var'))
    jpeg_hdr_quality = 95;
end

if(~exist('hdr_jpeg_2000_ratio','var'))
    hdr_jpeg_2000_ratio = 2;
end

extension = lower(fileExtension(filename));

if(strcmpi(extension,'pic')==1)
    extension='hdr';
end

switch extension
    
    %PIC-HDR format by Greg Ward (.hdr)
    case 'hdr'
        try
            write_rgbe(img,filename, 1);
        catch
            error('This PIC/HDR file can not be written.');
        end
        
    %Portable float map (.pfm)
    case 'pfm'
        try
            write_pfm(img,filename);
        catch
            error('This PFM file can not be written.');
        end
    
    %JPEG-HDR (.jpg)
    case 'jpg'
        try
            JPEGHDREnc(img, filename, jpeg_hdr_quality);
        catch
            error('This JPEG-HDR file can not be written.');
        end
        
    %HDR JPEG2000 (.jp2)
    case 'jp2'
         try
            HDRJPEG2000Enc(img, filename, hdr_jpeg_2000_ratio)
         catch
             error('This HDR JPEG 2000 file can not be written.');
         end        
        
    otherwise%try to save as LDR image
        try
            imwrite(ClampImg(img,0,1),filename);
        catch
            error('This format is not supported.');
        end
end

ret = 1;

end