function [imLc, imRc] = rectify_image_func (imL, imR, store_dir, image_name)

width = min(size(imL, 2), size(imR, 2));
height = min(size(imL, 1), size(imR, 1));

imL = imL(1 : height, 1 : width, :);
imR = imR(1 : height, 1 : width, :);

down = 1;
imL = imresize(imL,1/down,'bilinear');
imR = imresize(imR,1/down,'bilinear');

%cut_vert = round(size(imL,1) / 12);
%cut_hor = round(size(imL,1) / 12);

%imL = imL(1+cut_vert:end-cut_vert,1+cut_hor:end-cut_hor,:);
%imR = imR(1+cut_vert:end-cut_vert,1+cut_hor:end-cut_hor,:);

cd sift
%[imL imR] = zoomCorrect(imL, imR);
mps = matchpts(imL,imR);
cd ..

imsize = size(imL);

% Remove outliers based on initial vertical disparity
dy = mps(2,:) - mps(5,:);
dym = abs(dy - median(dy)); % distance from median
[dym_sort ix] = sort(dym);
max_ixs = ix(end- round(length(ix)*0.2):end); % find indexs of max 10% elements in dym
mps(:,max_ixs) = [];  % remove outliers


dy = round(median(mps(2,:) - mps(5,:)));

% max - everything inside screen, min - everything pop out

dx = round(prctile(mps(1, :), 85) - mps(4, :));
%dx = round(max(mps(1,:) - mps(4,:)));
%dx = round(median(mps(1,:) - mps(4,:)));

%dx = 24;

if (dy > 0)
    
    imLc = imL(1+dy:end,:,:);
    imRc = imR(1:end-dy,:,:);
else
    dy = abs(dy);
    imRc = imR(1+dy:end,:,:);
    imLc = imL(1:end-dy,:,:);
end

if (dx > 0)
    
    imLc = imLc(:,1+dx:end,:);
    imRc = imRc(:,1:end-dx,:);
else
    dx = abs(dx);
    imRc = imRc(:,1+dx:end,:);
    imLc = imLc(:,1:end-dx,:);
end

out_name = sprintf( '%s%s.jpg', store_dir, image_name);

imwrite( uint8([imLc imRc]), out_name, 'jpeg','quality',100);
% 

% anagylph = imRc;
% anagylph(:,:,1) = 0.7 * imLc(:,:,2) + 0.3*imLc(:,:,3);
% figure;
% imshow(anagylph);
% anagylph = imLc;
% anagylph(:,:,1) = 0.7 * imRc(:,:,2) + 0.3*imRc(:,:,3);
% figure;
% imshow(anagylph);

done = 1
