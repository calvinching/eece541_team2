clear all;
close all;

aviobj = avifile('bistro01_HybridTMO_nocheat.avi'); %creating a movie object
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
  outImage = hybrid_3x3_matrix(fullFileName);
  outImage = im2uint8(outImage);

  M = im2frame(outImage);%convert the images into frames
  aviobj = addframe(aviobj,M);%add the frames to the avi object created previously
end 

disp('Closing movie file...')
aviobj = close(aviobj);