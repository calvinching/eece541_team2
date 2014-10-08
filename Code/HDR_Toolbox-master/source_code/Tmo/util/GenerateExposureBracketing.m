function [stack, stack_exposure] = GenerateExposureBracketing( img, fstopDistance, geb_gamma, geb_mode )
%
%
%       stack = GenerateExposureBracketing( img )
%       
%
%        Input:
%           -img: input HDR image
%           -fstopDistance: delta f-stop for generating exposures
%           -geb_gamma: the gamma for encoding the images
%           -geb_mode: how to samples the image.
%                  - if geb_mode = 'uniform', exposures are sampled
%                    in an uniform way
%                  - if geb_mode = 'histogram', exposures are sampled using
%                    the histogram using a greedy approach
%
%        Output:
%           -stack: a stack of LDR images
%           -stack_exposure: exposure values of the stack (stored as time
%           in seconds)
% 
%     Copyright (C) 2010 Francesco Banterle
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

[r,c,col] = size(img);

if(~exist('fstopDistance','var'))
    fstopDistance = 1;
end

%inverse gamma
if(~exist('geb_gamma','var'))
    inv_gamma = 1.0/2.2;
else
    inv_gamma = 1.0/geb_gamma;
end

if(~exist('geb_mode','var'))
    geb_mode = 'histogram';
end

%luminance channel
L = lum(img);

switch(geb_mode)
    case 'histogram'
        stack_exposure = 2.^ExposureHistogramCovering(img);
        
    case 'uniform'
        MinL = MaxQuart(L(L>0.0),0.01);
        MaxL = MaxQuart(L(L>0.0),0.9999);

        minExposure = floor(log2(MaxL));
        maxExposure = ceil(log2(MinL));

        tMax = -(maxExposure-1);
        tMin = -(minExposure+1);
        stack_exposure = 2.^(tMin:fstopDistance:tMax);
        
    otherwise
        error('wrong mode for sampling the HDR image');
end

%allocate memory for the stack
n = length(stack_exposure);
stack = zeros(r,c,col,n);

%calculate exposures
for i=1:n
    expo = ClampImg((stack_exposure(i)*img).^inv_gamma,0,1);
    stack(:,:,:,i) = expo;
end

end

