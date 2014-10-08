function imgOut = MeylanEO(img, Meylan_Max, Meylan_lambda, gammaRemoval)
%
%       imgOut = MeylanEO(img, Meylan_Max, Meylan_lambda, gammaRemoval)
%
%
%        Input:
%           -img: input LDR image with values in [0,1]
%           -Meylan_Max: this value defines the maximum luminance output of
%           the final expanded image in cd/m^2
%           -Meylan_lambda: threshold for applying the iTMO
%           -gammaRemoval: the gamma value to be removed if known
%
%        Output:
%           -imgOut: an expanded image
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

%is it a three color channels image?
check13Color(img);

%default parameters
if(~exist('Meylan_Max','var'))    
    Meylan_Max=3000.0;   %Maximum value of DR-37P: 3000 cd/m^2 
end

if(~exist('Meylan_lambda','var'))
    Meylan_lambda=0.67; %standard diffuse part range
end

if(~exist('gammaRemoval','var'))
    gammaRemoval = -1;    %no gamma removal
end

%Gamma removal
if(gammaRemoval>0.0)
    img=img.^gammaRemoval;
end

%Luminance channel
Y = lum(img);
lmax = max(Y(:));

m = round(size(Y,1)/50);

%Filtering with a box filter of size m+1
Y_flt = imfilter(Y, fspecial('average',m));
t1    = max(Y_flt(:));

%Filtering with a box filter of size 2m+1
Y_flt = imfilter(Y, fspecial('average',2*m+1));
t2    = max(Y_flt(:));

%Thresholding the image luminance channel with threshold t1
mask = zeros(size(Y));
mask(Y>t1) = 1;

%Removing single pixels
mask = bwmorph(mask,'clean');

%n step Erosion and Dilatation
H=[1,1,1;1,0,1;1,1,1];
for i=1:1000
    %Mask2
    M1_conv_H = imfilter(mask, H);
    mask2 = ones(size(Y));
    mask2((mask==0)|(M1_conv_H<1)) = 0;

    %Mask3
    M2_conv_H = imfilter(mask2, H);
    mask3 = zeros(size(Y));
    mask3((mask2==1)|((M2_conv_H>3)&(Y>t2))) = 1;

    check = sum(sum(abs(mask-mask3)));%is the solution stable?    
    mask = mask3;
    if(check<1)
        break;
    end    
end

itD = find(mask==0); %Diffuse part
itS = find(mask==1); %Specular part

%Calculation of the curve constants
omega = min(Y(mask==1));
if(abs(1.0-omega)<1e6)%not in the original paper but to avoid singularities
    omega = 0.99;
end

s1 = Meylan_Max*Meylan_lambda/omega;
s2 = Meylan_Max*(1.0-Meylan_lambda)/(lmax-omega);

I_new = zeros(size(Y));
I_new(itD) = Y(itD)*s1;                     %Diffuse expansion
I_new(itS) = omega*s1+(Y(itS)-omega)*s2;    %Specular expansion

%Filtered luminance
F5 = fspecial('average',5);
I_lp = imfilter(I_new, F5);

%Smoothing mask
B_1 = zeros(size(Y));
B_1(Y>omega) = 1;

B_1_conv_H = imfilter(B_1,H);
B_2 = zeros(size(B_1));
B_2((B_1==1)|(B_1_conv_H>1)) = 1;

B_lp = imfilter(B_2, F5);

%The expanded part and its filtered version are blended using the mask 
I_final = I_new.*(1-B_lp) + I_lp.*B_lp;

%Removing the old luminance
imgOut = ChangeLuminance(img, Y, I_final);

end
