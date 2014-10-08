clear all;
close all;

myFolder = 'G:\EECE 541 - HDR Group\HDR Images\bistro_01';
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
filePattern = fullfile(myFolder, '*.hdr');
hdrFiles = dir(filePattern);
baseFileName = hdrFiles(k).name;
fullFileName = fullfile(myFolder, baseFileName);
fprintf(1, 'Now reading %s\n', fullFileName);
imageArray = read_radiance(fullFileName);
outImage1 = iCAM06_HDR(imageArray, 20000, 0.7, 1);
outImage2 = WardHistAdjTMO(imageArray);
outImage3 = ReinhardTMO(imageArray);
outImage4 = DurandTMO(imageArray);
%outImage = GammaTMO(outImage, 2.2, 0, 1);
 
subplot(2,2,1)
imshow(outImage1)
title('iCAM06 Method')

subplot(2,2,2)
imshow(outImage2);
title('WardHist Method')

subplot(2,2,3)
imshow(outImage3);
title('Reinhard Method')

subplot(2,2,4)
imshow(outImage4);
title('Durand Method')