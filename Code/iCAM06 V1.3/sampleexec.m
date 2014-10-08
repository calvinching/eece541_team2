clear all;
close all;

aviobj = avifile('compare.avi'); %creating a movie object
myFolder = 'C:\Users\Hiba\Desktop\HDR Group\bistro_01';
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
filePattern = fullfile(myFolder, '*.hdr');
hdrFiles = dir(filePattern);
for k = 1:10
  baseFileName = hdrFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  imageArray = read_radiance(fullFileName);
%   outImage = iCAM06_HDR(imageArray,20000, 0.7, 1);
outImage = newCam(imageArray,20000, 0.7, 1);
  M = im2frame(outImage);%convert the images into frames
  aviobj = addframe(aviobj,M);%add the frames to the avi object created previously
end 

disp('Closing movie file...')
aviobj = close(aviobj);

disp('Playing movie file...')
implay('compare.avi');