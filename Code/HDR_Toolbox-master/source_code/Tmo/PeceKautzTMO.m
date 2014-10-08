function imgOut = PeceKautzTMO( img, directory, format, imageStack, iterations, kernelSize)
%
%
%        imgOut = PeceKautzTMO( img, directory, format, imageStack, iterations, kernelSize)
%
%
%        Input:
%           -img: input HDR image
%           -directory: the directory where to fetch the exposure imageStack in
%           the case img=[]
%           -format: the format of LDR images ('bmp', 'jpg', etc) in case
%                    img=[] and the tone mapped images is built from a sequence of
%                    images in the current directory
%           -imageStack: an exposure stack of LDR images; in case img=[],
%                        and directory='' and format=''
%           -iterations: number of iterations for improving the movements'
%           mask
%           -kernelSize: size of the kernel for improving the movements' mask
%
%        Output:
%           -imgOut: tone mapped image
%
%        Note: Gamma correction is not needed because it works on gamma
%        corrected images.
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
%     The paper describing this technique is:
%     "Bitmap Movement Detection: HDR for Dynamic Scenes"
% 	  by Fabrizio Pece, Jan Kautz
%     in Conference on Visual Media Production (CVMP)
%     London, UK, November 2010
%

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

if(~exist('iterations'))
    iterations = 15;
end

if(~exist('kernelSize'))
    kernelSize = 5;
end

%number of images in the stack
[r,c,col,n] = size(imageStack);

%Computation of weights for each image
total  = zeros(r,c);
weight = ones(r,c,n);
for i=1:n
    %calculation of the weights
    weight(:,:,i) = MertensWellExposedness(imageStack(:,:,:,i));
end

[moveMask,num] = PeceKautzMoveMask(imageStack, iterations, kernelSize);

weight_move = zeros(r,c,n);
for i=0:num
    indx = find(moveMask==i);
    
    Wvec = zeros(n,1);
    for j=1:n
        W = weight(:,:,j);
        Wvec(j) = mean(W(indx));
    end
    [val,j] = max(Wvec);

    W = zeros(r,c);
    W(indx) = 1;
    weight_move(:,:,j) = weight_move(:,:,j) + W;
end

%Normalization of weights
for i=1:n
    total = total + weight_move(:,:,i);
end

for i=1:n
    weight_move(:,:,i) = RemoveSpecials(weight_move(:,:,i)./total);
end

%empty pyramid
tf=[];
for i=1:n
    %Laplacian pyramid: image
    pyrImg = pyrImg3(imageStack(:,:,:,i),@pyrLapGen);
    %Gaussian pyramid: weight   
    pyrW   = pyrGaussGen(weight_move(:,:,i));

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

disp('This algorithm outputs images with gamma encoding. Inverse gamma is not required to be applied!');
end

