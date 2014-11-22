function [ imgOut ] = im_contrast( img, contrast )
% im_contrast Modify the contrast of the image
%   Parameters:
%   - img: image to apply contrast modification
%   - contrast: contrast value (-255 to 255)

[Row, Col, RGB] = size(img);
imgOut = zeros(Row, Col, RGB);

factor = (259 * (contrast + 255)) / (255 * (259 - contrast));
for j=1:Col
    for i=1:Row
        imgOut(i,j,1) = truncate(factor * (double(img(i,j,1)) - 128.0) + 128.0);
        imgOut(i,j,2) = truncate(factor * (double(img(i,j,2)) - 128.0) + 128.0);
        imgOut(i,j,3) = truncate(factor * (double(img(i,j,3)) - 128.0) + 128.0);
    end
end
end

function valOut = truncate(val)
if val < 0
    valOut = 0;
elseif val > 255
    valOut = 255;
else
    valOut = val;
end
end