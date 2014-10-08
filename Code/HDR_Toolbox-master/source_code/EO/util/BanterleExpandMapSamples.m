function [splat_pos, splat_power, window] = BanterleExpandMapSamples(img, BEM_bColorRec, BEM_clamping_threshold, BEM_percent)
%
%		 [splat_pos, splat_power, window] = BanterleExpandMapSamples(img, BEM_bColorRec, BEM_clamping_threshold, BEM_percent)
%
%
%		 Input:
%			-img: an input image LDR image in the linear domain
%           -BEM_bColorRec: a boolean value. If it is set 1 the expand
%           map will be calculated for each color channel
%           -BEM_clamping_threshold: if it is greater than 0, this value
%           determines the threshold for clamping light sources. Otherwise
%           this parameter is estimated automatically.
%           -BEM_percent: values in (0,1]
%
%		 Output:
%			-splat_pos: an array with the positions of samples
%			-splat_pos: an array with the powers/colors of samples
%           -window: the maximum size of a window where a light can be if
%           uniform sampling is assumed
%
%     Copyright (C) 2011-13  Francesco Banterle
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

if(~exist('BEM_percent','var'))
    BEM_percent = 0.95;
else
    BEM_percent = ClampImg(BEM_percent,0.01,1.0);
end

%Median-cut for sampling img
[r,c,col] = size(img);
nLights = 2.^(round(log2(min([r,c]))+2));
[imgOut,lights] = MedianCut(img,nLights,0);

%Determing the samples clamping
window = round(max([r,c])/(2.0*sqrt(nLights)));
Lout = lum(imgOut);

if(BEM_clamping_threshold>=0)
    thresholdSamples = BEM_clamping_threshold;
else
    %Create the histogram
    H = zeros(length(lights),1);
    for i=1:length(lights)
        [X0,X1,Y0,Y1] = GenerateBBox(lights(i).x,lights(i).y,r,c,window);
        indx = find(Lout(Y0:Y1,X0:X1)>0);
        H(i) = length(indx);
    end

    %Sort H
    H = sort(H);
    Hcum = cumsum(H);
    percentile = round(nLights*BEM_percent);
    [val,indx] = min(abs(Hcum-percentile));
    thresholdSamples = H(indx);
end

%samples' clamping
if(thresholdSamples>0)
    imgOut_tmp = imgOut;
    Lout_tmp = Lout;
    for i=1:length(lights)
        [X0,X1,Y0,Y1] = GenerateBBox(lights(i).x,lights(i).y,r,c,window*3);
        indx = find(Lout(Y0:Y1,X0:X1)>0); 
        
        if(length(indx)<thresholdSamples)
            X=ClampImg(round(lights(i).x*c),1,c);
            Y=ClampImg(round(lights(i).y*r),1,r);
            imgOut_tmp(Y,X,:) = 0;
            Lout_tmp(Y,X) = 0;
        end
    end
    Lout = Lout_tmp;
    imgOut = imgOut_tmp;
end

[y,x] = find(Lout>0.0);
splat_pos = [x';y'];

if(BEM_bColorRec)   
    splat_power = zeros(length(x),col);
    for i=1:length(x)
        for j=1:col
            splat_power(i,j) = imgOut(y(i),x(i),j);
        end
    end
else
    splat_power = zeros(length(x),1);
    for i=1:length(x)
        splat_power(i,1) = Lout(y(i),x(i));
    end    
end

clear('imgOut');
clear('Lout');

end