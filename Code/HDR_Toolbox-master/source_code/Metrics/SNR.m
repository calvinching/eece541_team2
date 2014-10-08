function val = SNR(imgReference, imgDistorted)
%
%
%      val = SNR(img1, img2)
%
%
%       Input:
%           -imgReference: reference image
%           -imgDistorted: distoreted image
%
%       Output:
%           -val: classic SNR for images in dB. Higher values means better quality.
% 
%     Copyright (C) 2014  Francesco Banterle
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

if(CheckSameImage(imgReference, imgDistorted)==0)
    error('The two images are different they can not be used.');
end

imgNoise2 = (imgReference-imgDistorted).^2;
imgReference2 = imgReference.^2;

tmp1 = sum(imgReference2(:));
tmp2 = sum(imgNoise2(:));

if(tmp2>0.0)
    val = 10*log10(tmp1/tmp2);
else
    disp('the images are the same');
    val = 1000.0;
end

end