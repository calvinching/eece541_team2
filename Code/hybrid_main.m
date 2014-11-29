clear all;
close all;

aviobj = avifile('bistro01_HybridTMO3.avi', 'fps', 30, 'quality', 100); %creating a movie object
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
%     ward_img = WardHistAdjTMO(im,255);
%     ward_img = GammaTMO(ward_img, 2.2, 0, 0);
%     ward_img = real(ward_img);
%     outImage = im2uint8(ward_img);
    outImage = hybrid_3x3_matrix(fullFileName);
    outImage = im2uint8(outImage);

    M = im2frame(outImage);%convert the images into frames
    aviobj = addframe(aviobj,M);%add the frames to the avi object created previously
end 

disp('Closing movie file...')
aviobj = close(aviobj);