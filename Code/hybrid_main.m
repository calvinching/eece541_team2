clear all;
close all;

aviobj = avifile('bistro01_HybridTMO_9.avi', 'fps', 30, 'quality', 100); %creating a movie object
myFolder = '../HDRImages/bistro_01';
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
filePattern = fullfile(myFolder, '*.hdr');
hdrFiles = dir(filePattern);
for k = 1:150 %length(hdrFiles)
    baseFileName = hdrFiles(k).name;
    fullFileName = fullfile(myFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    im = hdrimread(fullFileName);
%     if (k == 33)
%         asdf = 1;
%     end
%     ward_img = WardHistAdjTMO(im,5);
%     ward_img = GammaTMO(ward_img, 2.2, 0, 0);
%     ward_img = real(ward_img);
%     outImage = im2uint8(ward_img);
%     luminance = lum(im);
%     max_lum_ori = max(luminance(:));
%     iCAM_img_uint8 = iCAM06_HDR(im, max_lum_ori, 0.7, 1.3);
%     iCAM_img = double(iCAM_img_uint8)/255.0;
%     iCAM_img = GammaTMO(iCAM_img, 2.2, 0, 0);
%     outImage = real(iCAM_img);
    outImage = hybrid_3x3_matrix(fullFileName);
    outImage = im2uint8(outImage);

    M = im2frame(outImage);%convert the images into frames
    aviobj = addframe(aviobj,M);%add the frames to the avi object created previously
end 

disp('Closing movie file...')
aviobj = close(aviobj);