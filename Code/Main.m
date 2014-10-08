clear all;
close all;

aviobj = avifile('bistro01_iCAM06TMO.avi'); %creating a movie object
myFolder = '/Users/calvinching/Documents/ubc/eece_541/project/HDRImages/bistro_01';
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
filePattern = fullfile(myFolder, '*.hdr');
hdrFiles = dir(filePattern);
for k = 1:100%length(hdrFiles)
  baseFileName = hdrFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  imageArray = read_radiance(fullFileName);
  outImage = iCAM06_HDR(imageArray, 20000, 0.7, 1);
%  outImage = WardHistAdjTMO(imageArray);
%  outImage = GammaTMO(outImage, 2.2, 0, 1);
  M = im2frame(outImage);%convert the images into frames
  aviobj = addframe(aviobj,M);%add the frames to the avi object created previously
end 

disp('Closing movie file...')
aviobj = close(aviobj);

disp('Playing movie file...')
% implay('bistro02_iCam.avi');

% clear all;
% close all;
% 
% % matlabVfile1='bistro03.avi';
% matlabVfile2='glass.avi';
% matlabVfile3='glass1.avi';
% % matlabVfile4='bistro03.avi';
% outVideo1=concatVideo2D('fileNames',{matlabVfile2,matlabVfile3},'subVrows',1,'subVcols',2);
% implay(outVideo1);