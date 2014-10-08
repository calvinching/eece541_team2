%==========================================================================
%This program reads in HDR images, calls 5 different TMO function from 
%library and writes the tone-mapped LDR images into videos

%Input: data-set bistro01
%Output: 5 tone-mapped videos

%Created in April,2014, by HDR group
%==========================================================================


clear
dir_Bistro03_hdr = ('/Users/calvinching/Documents/ubc/eece_541/project/HDRImages/bistro_01/'); % Dirctory of HDR image
 
%=================================Durrand==================================
outputVideoDurrand1 = avifile('Durrand_bistro01.avi'); % Video output
% open(outputVideoDurrand1);

%==============================TumblinRushmeier============================
outputVideoTum1 = avifile('TumblinRushmeier_bistro01.avi'); % Video output
% open(outputVideoTum1);

%================================Logarithmic===============================
outputVideoLog1 = avifile('Logarithmic_bistro01.avi'); % Video output
% open(outputVideoLog1);

%================================Lischinski================================
outputVideoLis1 = avifile('Lischinski_bistro01.avi'); % Video output
% open(outputVideoLis1);

%===============================ReinhardBil================================
outputVideoRein1 = avifile('ReinhardBil_bistro01.avi'); % Video output
% open(outputVideoRein1);


difference=0.2; % Threshold

filename = sprintf('bistro_01_000295.hdr');
file = [dir_Bistro03_hdr, filename];
image=hdrimread(file);
% luminance=rgb2gray(image);
% mean_durrand_hdr(1)=mean2(luminance); % Calculate average luminance


% Tone-map the first frame  - Durrand=====================================
imgTMO_durrand =  DurandTMO(image, 30,100);
imgTMO_durrand = ClampImg(GammaTMO(imgTMO_durrand, 2.2, 0, 0), 0, 1);

luminance=rgb2gray(imgTMO_durrand);
mean_durrand_original(1)=mean2(luminance);
mean_durrand_new(1)=mean_durrand_original(1);
% imwrite(imgTMO, file);
frame=im2frame(imgTMO_durrand);
outputVideoDurrand1=addframe(outputVideoDurrand1,frame);


% Tone-map the first frame  - TumblinRushmeier=============================
imgTMO_tum = TumblinRushmeierTMO(image, 25,100,100);
imgTMO_tum = ClampImg(GammaTMO(imgTMO_tum, 2.2, 0, 0), 0, 1);

luminance=rgb2gray(imgTMO_tum);
mean_tum_original(1)=mean2(luminance);
mean_tum_new(1)=mean_tum_original(1);
% imwrite(imgTMO, file);
frame=im2frame(imgTMO_tum);
outputVideoTum1=addframe(outputVideoTum1,frame);


% Tone-map the first frame  - Logarithmic==================================
imgTMO_log = LogarithmicTMO(image, 10,1);
imgTMO_log = ClampImg(GammaTMO(imgTMO_log, 2.2, 0, 0), 0, 1);

luminance=rgb2gray(imgTMO_log);
mean_log_original(1)=mean2(luminance);
mean_log_new(1)=mean_log_original(1);
% imwrite(imgTMO, file);

frame=im2frame(imgTMO_log);
outputVideoLog1=addframe(outputVideoLog1,frame);

% Tone-map the first frame  - Lischinski===================================
imgTMO_Lis = LischinskiTMO(image, 0.15);
imgTMO_Lis = ClampImg(GammaTMO(imgTMO_Lis, 2.2, 0, 0), 0, 1);

luminance=rgb2gray(imgTMO_Lis);
mean_Lis_original(1)=mean2(luminance);
mean_Lis_new(1)=mean_Lis_original(1);
% imwrite(imgTMO, file);

frame=im2frame(imgTMO_Lis);
outputVideoLis1=addframe(outputVideoLis1,frame);

% Tone-map the first frame  - ReinhardBil=================================
imgTMO_Rein = ReinhardBilTMO(image, 0.1);
imgTMO_Rein = ClampImg(GammaTMO(imgTMO_Rein, 2.2, 0, 0), 0, 1);

luminance=rgb2gray(imgTMO_Rein);
mean_Rein_original(1)=mean2(luminance);
mean_Rein_new(1)=mean_Rein_original(1);
% imwrite(imgTMO, file);

frame=im2frame(imgTMO_Rein);
outputVideoRein1=addframe(outputVideoRein1,frame);


% Tone-map the rest frames
for K=2:151
    K
filename = sprintf('bistro_01_00%04d.hdr', K+294);
file = [dir_Bistro03_hdr, filename];
image=hdrimread(file);

%=================================Durrand==================================
imgTMO_durrand =  DurandTMO(image, 30,100);
imgTMO_durrand = ClampImg(GammaTMO(imgTMO_durrand, 2.2, 0, 0), 0, 1);

luminance=rgb2gray(imgTMO_durrand);
mean_durrand_original(K)=mean2(luminance);
mean_durrand_new(K)=mean2(luminance);

%Change the luminance
if (abs(mean_durrand_new(K)-mean_durrand_new(K-1))*255)>difference
    if (mean_durrand_new(K)-mean_durrand_new(K-1))>0
        factor=mean_durrand_new(K-1)*255+difference;
    else
        factor=mean_durrand_new(K-1)*255-difference;
    end
    
    imgTMO_durrand(:,:,1)=imgTMO_durrand(:,:,1)*factor/mean_durrand_new(K)/255;
    imgTMO_durrand(:,:,2)=imgTMO_durrand(:,:,2)*factor/mean_durrand_new(K)/255;
    imgTMO_durrand(:,:,3)=imgTMO_durrand(:,:,3)*factor/mean_durrand_new(K)/255;
    luminance=rgb2gray(imgTMO_durrand);
    mean_durrand_new(K)=mean2(luminance);
end

imgTMO_durrand = ClampImg(imgTMO_durrand, 0, 1);

frame=im2frame(imgTMO_durrand);
outputVideoDurrand1=addframe(outputVideoDurrand1,frame);



%=============================TumblinRushmeier=============================
imgTMO_tum = TumblinRushmeierTMO(image, 25,100,100);
imgTMO_tum = ClampImg(GammaTMO(imgTMO_tum, 2.2, 0, 0), 0, 1);

luminance=rgb2gray(imgTMO_tum);
mean_tum_original(K)=mean2(luminance);
mean_tum_new(K)=mean2(luminance);

%Change the luminance
if (abs(mean_tum_new(K)-mean_tum_new(K-1))*255)>difference
    if (mean_tum_new(K)-mean_tum_new(K-1))>0
        factor=mean_tum_new(K-1)*255+difference;
    else
        factor=mean_tum_new(K-1)*255-difference;
    end
    
    imgTMO_tum(:,:,1)=imgTMO_tum(:,:,1)*factor/mean_tum_new(K)/255;
    imgTMO_tum(:,:,2)=imgTMO_tum(:,:,2)*factor/mean_tum_new(K)/255;
    imgTMO_tum(:,:,3)=imgTMO_tum(:,:,3)*factor/mean_tum_new(K)/255;
    luminance=rgb2gray(imgTMO_tum);
    mean_tum_new(K)=mean2(luminance);
end

imgTMO_tum = ClampImg(imgTMO_tum, 0, 1);

frame=im2frame(imgTMO_tum);
outputVideoTum1=addframe(outputVideoTum1,frame);



%================================Logarithmic===============================
imgTMO_log = LogarithmicTMO(image, 10,1);
imgTMO_log = ClampImg(GammaTMO(imgTMO_log, 2.2, 0, 0), 0, 1);

luminance=rgb2gray(imgTMO_log);
mean_log_original(K)=mean2(luminance);
mean_log_new(K)=mean2(luminance);

%Change the luminance
if (abs(mean_log_new(K)-mean_log_new(K-1))*255)>difference
    if (mean_log_new(K)-mean_log_new(K-1))>0
        factor=mean_log_new(K-1)*255+difference;
    else
        factor=mean_log_new(K-1)*255-difference;
    end
    
    imgTMO_log(:,:,1)=imgTMO_log(:,:,1)*factor/mean_log_new(K)/255;
    imgTMO_log(:,:,2)=imgTMO_log(:,:,2)*factor/mean_log_new(K)/255;
    imgTMO_log(:,:,3)=imgTMO_log(:,:,3)*factor/mean_log_new(K)/255;
    luminance=rgb2gray(imgTMO_log);
    mean_log_new(K)=mean2(luminance);
end

imgTMO_log = ClampImg(imgTMO_log, 0, 1);
frame=im2frame(imgTMO_log);
outputVideoLog1=addframe(outputVideoLog1,frame);




%===============================Lischinski=================================
imgTMO_Lis = LischinskiTMO(image, 0.15);
imgTMO_Lis = ClampImg(GammaTMO(imgTMO_Lis, 2.2, 0, 0), 0, 1);

luminance=rgb2gray(imgTMO_Lis);
mean_Lis_original(K)=mean2(luminance);
mean_Lis_new(K)=mean2(luminance);

%Change the luminance
if (abs(mean_Lis_new(K)-mean_Lis_new(K-1))*255)>difference
    if (mean_Lis_new(K)-mean_Lis_new(K-1))>0
        factor=mean_Lis_new(K-1)*255+difference;
    else
        factor=mean_Lis_new(K-1)*255-difference;
    end
    
    imgTMO_Lis(:,:,1)=imgTMO_Lis(:,:,1)*factor/mean_Lis_new(K)/255;
    imgTMO_Lis(:,:,2)=imgTMO_Lis(:,:,2)*factor/mean_Lis_new(K)/255;
    imgTMO_Lis(:,:,3)=imgTMO_Lis(:,:,3)*factor/mean_Lis_new(K)/255;
    luminance=rgb2gray(imgTMO_Lis);
    mean_Lis_new(K)=mean2(luminance);
end

imgTMO_Lis = ClampImg(imgTMO_Lis, 0, 1);

frame=im2frame(imgTMO_Lis);
outputVideoLis1=addframe(outputVideoLis1,frame);




%==============================ReinhardBil=================================
imgTMO_Rein = ReinhardBilTMO(image, 0.1);
imgTMO_Rein = ClampImg(GammaTMO(imgTMO_Rein, 2.2, 0, 0), 0, 1);

luminance=rgb2gray(imgTMO_Rein);
mean_Rein_original(K)=mean2(luminance);
mean_Rein_new(K)=mean2(luminance);

%Change the luminance
if (abs(mean_Rein_new(K)-mean_Rein_new(K-1))*255)>difference
    if (mean_Rein_new(K)-mean_Rein_new(K-1))>0
        factor=mean_Rein_new(K-1)*255+difference;
    else
        factor=mean_Rein_new(K-1)*255-difference;
    end
    
    imgTMO_Rein(:,:,1)=imgTMO_Rein(:,:,1)*factor/mean_Rein_new(K)/255;
    imgTMO_Rein(:,:,2)=imgTMO_Rein(:,:,2)*factor/mean_Rein_new(K)/255;
    imgTMO_Rein(:,:,3)=imgTMO_Rein(:,:,3)*factor/mean_Rein_new(K)/255;
    luminance=rgb2gray(imgTMO_Rein);
    mean_Rein_new(K)=mean2(luminance);
end

imgTMO_Rein = ClampImg(imgTMO_Rein, 0, 1);

frame=im2frame(imgTMO_Rein);
outputVideoRein1=addframe(outputVideoRein1,frame);

end

outputVideoDurrand1=close(outputVideoDurrand1);
outputVideoTum1=close(outputVideoTum1);
outputVideoLog1=close(outputVideoLog1);
outputVideoLis1=close(outputVideoLis1);
outputVideoRein1=close(outputVideoRein1);