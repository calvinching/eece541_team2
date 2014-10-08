%
%       HDR Toolbox demo Fusion:
%	   1) Apply Fusion Operator by Raman and Chaudhuri at images in stack folder
%	   2) Show the image without gamma encoding, because it is working in
%	   gamma space
%	   3) Save the tone mapped image as PNG
%	   4) Apply Fusion Operator by Mertne and Chaudhuri at images in stack folder
%	   5) Show the image without gamma encoding, because it is working in
%	   gamma space
%	   6) Save the tone mapped image as PNG
%       Author: Francesco Banterle
%       Copyright June 2012 (c)
%
%

disp('1) Applying Fusion Operator by Raman and Chaudhuri to images in stack folder');
imgTMO = RamanTMO([],'stack','jpg');

disp('2) Showing the image after fusion, note that there is no need of gamma correction!');
h = figure(1);
set(h,'Name','Raman and Chaudhuri exposure fusion (no need of gamma encoding)');
GammaTMO(imgTMO, 1.0, 0, 1);

disp('3) Saving the tone mapped image as a PNG.');
imwrite(imgTMO, 'venice_calle_raman_TMO.png');

disp('4) Applying Fusion Operator by Mertens et al to images in stack folder');
imgTMO = MertensTMO([],'stack','jpg',[],1,1,1);

disp('5) Showing the image after fusion, note that there is no need of gamma correction!');
h = figure(2);
set(h,'Name','Mertens et al. exposure fusion (no need of gamma encoding)');
GammaTMO(imgTMO, 1.0, 0, 1);
disp('6) Saving the tone mapped image as a PNG.');
imwrite(imgTMO, 'venice_calle_mertens_TMO.png');
