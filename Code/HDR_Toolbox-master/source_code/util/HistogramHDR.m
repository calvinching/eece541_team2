function [histo,bound,haverage]=HistogramHDR(img,nZone,typeLog,bNormalized,bPlot)
%
%
%        [histo,bound,haverage]=HistogramHDR(img,nZone,typeLog,bNormalized,bPlot)
%
%
%        Input:
%           -img: input HDR image
%           -nZone: number of bins for calculating the histogram
%           -typeLog: type of space for calculating the histogram: 'linear'
%           for linear space, 'log2' for base 2 logarithm space, 'loge', for
%           natural logarithm space, 'log10' for base 10 logarithm space
%           -bNormalized: the histogram is normalized
%           -bPlot: if it is true the histogram is visualised
%
%        Output:
%           -histo: the histogram of the image
%           -bound: maximum and minimu values of the histogram
%           -haverage: the average of values in the histogram
%
%     Copyright (C) 2011  Francesco Banterle
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

%is it a three color channels image?
check13Color(img);

if(~exist('nZone','var'))
    nZone = 256;
end

if(~exist('typeLog','var'))
    typeLog = 'log10';
end

if(~exist('bNormalized','var'))
    bNormalized = 0;
end

if(~exist('bPlot','var'))
    bPlot=0;
end

L  = lum(img);
L  = L(:);
L2 = L;

delta=1e-6;
switch typeLog       
    case 'log2'
    	L=log2(L+delta);
    case 'loge'
        L=log(L+delta);
    case 'log10'
    	L=log10(L+delta);
end

Lmin = min(L);
Lmax = max(L);
dMM  = (Lmax-Lmin)/(nZone-1);

histo=zeros(nZone,1);

bound(1) = Lmin;
bound(2) = Lmax;

haverage = 0;
total = 0;
for i=1:nZone
    indx  = find(L>=(dMM*(i-1)+Lmin)&L<(dMM*i+Lmin));
    count = length(indx);
    if(count>0)
        histo(i) = count;
        haverage = haverage+MaxQuart(L2(indx),0.5)*count;
        total    = total+count;
    end
end

if(bNormalized)
    norm = sum(histo);
    if(norm>0)
        histo = histo/norm;
    end
end

haverage = haverage/(total);

if(bPlot)
    x=((1:nZone)/nZone)*(Lmax-Lmin)+Lmin;
    bar(x,histo);
end

end