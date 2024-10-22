clear all;
close all;

aviobj = avifile('bistro01_HybridTMO.avi', 'fps', 30, 'quality', 100); %creating a movie object
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

    curImage = hybrid_tmo(fullFileName);

    if (k == 1)
        prevImage = curImage;
    else
        outImage_hsv = rgb2hsv(curImage); % convert to L*a*b*
        prevImage_hsv = rgb2hsv(prevImage); % convert to L*a*b*

        outImage_hsv(:,:,3) = (prevImage_hsv(:,:,3) + outImage_hsv(:,:,3)) * 0.5;
        outImage = hsv2rgb(outImage_hsv); % convert back to RGB

        outImage = im2uint8(outImage);
        prevImage = curImage;

        M = im2frame(outImage);%convert the images into frames
        aviobj = addframe(aviobj, M);%add the frames to the avi object created previously
    end
end

disp('Closing movie file...')
aviobj = close(aviobj);