function imgOut = ZhangChamGradientTMO(img, directory, format, imageStack, bStatic)
%
%
%        imgOut = ZhangChamGradientTMO(img, directory, format, imageStack)
%
%
%        Input:
%           -img: input HDR image
%           -directory: the directory where to fetch the exposure imageStack in
%           the case img=[]
%           -format: the format of LDR images ('bmp', 'jpg', etc) in case
%                    img=[] and the tone mapped images is built from a sequence of
%                    images in the current directory
%           -imageStack:
%           -bStatic: determing if the scene is static or not
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

%imageStack generation
if(~exist('imageStack','var'))
    imageStack = [];
end

if(~exist('bStatic','var'))
    bStatic = 1;
end

if(~isempty(img))
    %Convert the HDR image into a imageStack
    [imageStack,imageStack_exposure] = GenerateExposureBracketing(img,1);
else
    if(isempty(imageStack))
        imageStack = ReadLDRStack(directory, format)/255.0;
    end
end

%extracting gradients
[r,c,col,n] = size(imageStack);

grad_mag = zeros(r,c,n);
grad_ori = zeros(r,c,n);

mag_total = zeros(r,c);
for i=1:n
    L = lum(imageStack(:,:,:,i));
    
    window_size = 5;
    kernel_gauss = fspecial('gaussian',window_size,GKSigma(window_size));
    [kgx,kgy] = gradient(kernel_gauss);
    
    gx = imfilter(L,kgx,'replicate');
    gy = imfilter(L,kgy,'replicate');
    
    grad_mag(:,:,i) = sqrt(gx.^2+gy.^2);
    grad_ori(:,:,i) = atan2(gy, gx);
    
    mag_total = mag_total + grad_mag(:,:,i); 
end

epsilon = 1e-25; %as in the original paper;

if(~bStatic)%Dynamic scene
    %Computing the visibility measure V_i; Equation 2 of the original paper
    V = zeros(r,c,n);
    for i=1:n
        V(:,:,i) = grad_mag(:,:,i)./(mag_total+epsilon);
    end
    clear('grad_mag');
    clear('mag_total');

    %Computing consistency measure
    C = zeros(r,c,n);
    C_total = zeros(r,c);
    for i=1:n
        S_i = ZhangCham_Score(grad_ori, i);
        alpha_i = ZhangCham_Alpha(lum(imageStack(:,:,:,i)));

        C(:,:,i) = S_i.*alpha_i;    
        C_total =  C_total + C(:,:,i);    
    end

    clear('grad_ori');
    
    for i=1:n
        C(:,:,i) = C(:,:,i)./(C_total+epsilon);
    end

    clear('C_total');


    %Final weights
    W = zeros(r,c,n);
    W_total = zeros(r,c);

    for i=1:n
        W(:,:,i) = V(:,:,i).*C(:,:,i);
        W_total = W_total + W(:,:,i);
    end

    clear('V');
    clear('C');

    imgOut = zeros(r,c,col);
    total = zeros(r,c);
    for i=1:n      
        W_i = W(:,:,i)./W_total;
        W_i = bilateralFilter(W_i,double(lum(imageStack(:,:,:,i))));%,0.0,1.0,5,5/255);
        for j=1:col
            imgOut(:,:,j) = imgOut(:,:,j) + W_i.*imageStack(:,:,j,i);
        end
        total = total + W_i;
    end
    
    for j=1:col
        imgOut(:,:,j) = imgOut(:,:,j)./(total+epsilon);
    end      
else
    imgOut = zeros(r,c,col);
    total = zeros(r,c);
    for i=1:n      
        V_i = grad_mag(:,:,i)./(mag_total+epsilon);
        V_i = bilateralFilter(V_i,double(lum(imageStack(:,:,:,i))));%,0.0,1.0,5,5/255);
        for j=1:col
            imgOut(:,:,j) = imgOut(:,:,j) + V_i.*imageStack(:,:,j,i);
        end
        total = total + V_i;
    end
    
    for j=1:col
        imgOut(:,:,j) = imgOut(:,:,j)./(total+epsilon);
    end    
end

disp('This algorithm outputs images with gamma encoding. Inverse gamma is not required to be applied!');
end