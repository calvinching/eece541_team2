function imgOut = MertensTMO( img, directory, format, imageStack, wE, wS, wC, bMertensDebug )
%
%
%        imgOut = MertensTMO( img, directory, format, imageStack, wE, wS, wC )
%
%
%        Input:
%           -img: input HDR image
%           -directory: the directory where to fetch the exposure stack in
%           the case img=[]
%           -format: the format of LDR images ('bmp', 'jpg', etc) in case
%                    img=[] and the tone mapped images is built from a sequence of
%                    images in the current directory
%           -imageStack: an exposure stack of LDR images; in case img=[],
%                        and directory='' and format=''
%           -wE: the weight for the well exposedness in [0,1]. Well exposed
%                pixels are taken more into account if the wE is near 1
%                otherwise they are not taken into account.
%           -wS: the weight for the saturation in [0,1]. Saturated
%                pixels are taken more into account if the wS is near 1
%                otherwise they are not taken into account.
%           -wC: the weight for the contrast in [0,1]. Strong edgese are 
%                taken more into account if the wE is near 1
%                otherwise they are not taken into account.
%           -bMertensDebug: a debugging flag to turn on/off the gamma
%           encoding notice.
%
%        Output:
%           -imgOut: tone mapped image
%
%        Note: Gamma correction is not needed because it works on gamma
%        corrected images.
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

%default parameters if they are missing
if(~exist('wE','var'))
    wE = 1.0;
end

if(~exist('wS','var'))
    wS = 1.0;
end

if(~exist('wC','var'))
    wC = 1.0;
end

if(~exist('bMertensDebug','var'))
    bMertensDebug = 1;
end

%imageStack generation
if(~exist('imageStack','var'))
    imageStack = [];
end

if(~isempty(img))
    %Convert the HDR image into a imageStack
    [imageStack,imageStack_exposure] = GenerateExposureBracketing(img,1);
else
    if(isempty(imageStack))
        imageStack = ReadLDRStack(directory, format)/255.0;
    end
end


%number of images in the stack
[r,c,col,n] = size(imageStack);

%Computation of weights for each image
total  = zeros(r,c);
weight = ones(r,c,n);
for i=1:n
    %calculation of the weights
    if(wE>0.0)
        weightE = MertensWellExposedness(imageStack(:,:,:,i));
        weight(:,:,i) = weight(:,:,i) .* weightE.^wE;
    end
    
    if(wC>0.0)
        L = mean(imageStack(:,:,:,i),3);  
        weightC = MertensContrast(L);
        weight(:,:,i) = weight(:,:,i) .* (weightC.^wC);
    end

    if(wS>0.0)
        weightS = MertensSaturation(imageStack(:,:,:,i));
        weight(:,:,i) = weight(:,:,i) .* (weightS.^wS);
    end
    
    weight(:,:,i) = weight(:,:,i)+1e-12;
    
    total = total + weight(:,:,i);
end

%Normalization of weights
for i=1:n
    weight(:,:,i) = weight(:,:,i)./total;
end

%empty pyramid
tf=[];
for i=1:n
    %Laplacian pyramid: image
    pyrImg = pyrImg3(imageStack(:,:,:,i),@pyrLapGen);
    %Gaussian pyramid: weight   
    pyrW   = pyrGaussGen(weight(:,:,i));

    %Multiplication image times weights
    tmpVal = pyrLstS2OP(pyrImg,pyrW,@pyrMul);
   
    if(i==1)
        tf = tmpVal;
    else
        %accumulation
        tf = pyrLst2OP(tf,tmpVal,@pyrAdd);    
    end
end

%Evaluation of Laplacian/Gaussian Pyramids
imgOut=zeros(r,c,col);
for i=1:col
    imgOut(:,:,i) = pyrVal(tf(i));
end

%Clamping
imgOut = ClampImg(imgOut/max(imgOut(:)),0.0,1.0);

if(bMertensDebug)
    disp('This algorithm outputs images with gamma encoding. Inverse gamma is not required to be applied!');
end

end