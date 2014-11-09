 
close all;
clear all;

tileSize = 5;

%load original image
im = hdrimread('bistro_01_000295.hdr');
luminance = lum(im);
figure('Name', 'Original Image'),imshow(im);

%initialize required matrix
[Row, Col, RGB] = size(im);
modified = zeros(Row,Col);
edgeExpand = zeros(Row,Col);
imageOut = zeros(Row,Col,RGB);
kernel = zeros(5,5);

%fill kernel with weightings percentage
kernel = [10,10,10,10,10,10,10,10,10,10,10;
          10,20,20,20,20,20,20,20,20,20,10;
          10,20,40,40,40,40,40,40,40,20,10;
          10,20,40,60,60,60,60,60,40,20,10;
          10,20,40,60,80,80,80,60,40,20,10;
          10,20,40,60,80,90,80,60,40,20,10;
          10,20,40,60,80,80,80,60,40,20,10;
          10,20,40,60,60,60,60,60,40,20,10;
          10,20,40,40,40,40,40,40,40,20,10;
          10,20,20,20,20,20,20,20,20,20,10;
          10,10,10,10,10,10,10,10,10,10,10];

%edge detection applied to original image
[edge_mask, dir] = edge(luminance, 'canny');
figure('Name', 'Edge Mask'),imshow(edge_mask);

%convert rad to deg and convert to 0 to 360 degrees
deg = radtodeg(dir);
for j=1:1:Col
    for i=1:1:Row
        if deg(i,j) < 0
            deg(i,j) = 360 + deg(i,j);
        end
    end
end 
[v,ind]=max(deg);
[v1,ind1]=max(max(deg));
disp(sprintf('The largest element in deg matrix is %f at (%d,%d).', v1, ind(ind1), ind1 ));


%3x3 masking of the edge 
for j=2:1:Col-1
    for i=2:1:Row-1
        if((edge_mask(i,j) == 1)||((edge_mask(i,j-1) == 1)||(edge_mask(i,j+1) == 1)||(edge_mask(i-1,j-1) == 1)||(edge_mask(i-1,j) == 1)||(edge_mask(i-1,j+1) == 1)||(edge_mask(i+1,j-1) == 1)||(edge_mask(i+1,j) == 1)||(edge_mask(i+1,j+1) == 1)))
            r = randi([1,9],1,2);
            if (r(1,1) == 1 || r(1,2) == 1)
                edgeExpand(i,j) = 1;
            end
            if (r(1,1) == 2 || r(1,2) == 2)
                edgeExpand(i,j-1) = 1;
            end
            if (r(1,1) == 3 || r(1,2) == 3)
                edgeExpand(i,j+1) = 1;
            end
            if (r(1,1) == 4 || r(1,2) == 4)
                edgeExpand(i-1,j-1) =1;
            end
            if (r(1,1) == 5 || r(1,2) == 5)
                edgeExpand(i-1,j) = 1;
            end
            if (r(1,1) == 6 || r(1,2) == 6)
                edgeExpand(i-1,j+1) =1;
            end
            if (r(1,1) == 7 || r(1,2) == 7)
                edgeExpand(i+1,j-1) = 1;
            end
            if (r(1,1) == 8 || r(1,2) == 8)
                edgeExpand(i+1,j) = 1;
            end
            if (r(1,1) == 9 || r(1,2) == 9)
                edgeExpand(i+1,j+1) = 1;
            end
        else
             edgeExpand(i,j) = 0;
             edgeExpand(i,j-1) = 0;
             edgeExpand(i,j+1) = 0;
             edgeExpand(i-1,j-1) = 0;
             edgeExpand(i-1,j) = 0;
             edgeExpand(i-1,j+1) = 0;
             edgeExpand(i+1,j-1) = 0; 
             edgeExpand(i+1,j) = 0;
             edgeExpand(i+1,j+1) = 0;
        end
    end
end

for j=1:2
    for i=1:1
        if((edge_mask(i,j) == 1)||((edge_mask(i,j+1) == 1)||(edge_mask(i+1,j) == 1)||(edge_mask(i+1,j+1) == 1)))
               edgeExpand(i,j) = 1; 
               edgeExpand(i,j+1) =1;
               edgeExpand(i+1,j) =1;
               edgeExpand(i+1,j+1) =1;
        else
               edgeExpand(i,j)= 0; 
               edgeExpand(i,j+1)=0;
               edgeExpand(i+1,j)=0;
               edgeExpand(i+1,j+1)=0;
        end
    end
end

%apply iCAM and Ward TMO to original image
iCAM_img = iCAM06_HDR(im, 20000, 0.7, 1);
iCAM_img = double(iCAM_img)/255.0;
ward_img = WardHistAdjTMO(im, 5);

%generate final image based on expanded edge mask with weighting
for j=1:Col
    for i=1:Row
        if(edgeExpand(i,j) == 1)
            imageOut(i,j,:) = (0.90)*iCAM_img(i,j,:) + (0.1)*ward_img(i,j,:);
        else
            imageOut(i,j,:) = (0.80)*ward_img(i,j,:) + (0.20)*iCAM_img(i,j,:);
        end
    end
end

%smoothing algorithm 
for j=1:1:Col
    %check for pixels around left & right border of the image
    if j < tileSize + 1
        jlimit = j - 1;
    elseif j > Col - tileSize;
        jlimit = Col - tileSize;
    else
        jlimit = tileSize;
    end
    for i=1:1:Row
        %check for pixels around top & bottom border of the image
        if i < tileSize + 1
            ilimit = i - 1;
        elseif i > Row - tileSize;
            ilimit = Row - tileSize;
        else
            ilimit = tileSize;
        end
        %check edge bitmask to find edges (e.g. edgeExpand == 1)
        if edgeExpand(i,j) == 1
            angle = deg(i,j);
            mode = ceil(angle/45);
            switch mode
                case 1
                    coneLayer = 0;
                    %loop for cone area generation for smoothing
                    for m=(j+1):1:(j + jlimit)
                        coneLayer = coneLayer + 1;
                        factor = coneLayer * 0.2;
                        for n=(i - coneLayer):1:(i + coneLayer)
                            if modified(n,m) == 0;
                                imageOut(n,m,:) = (((1-factor)^2)*iCAM_img(n,m,:) + (1-(1-factor)^2)*ward_img(n,m,:));
                                modified(n,m) = 1;
                            else
                                imageOut(n,m,:)= ((((1-factor)^2)*iCAM_img(n,m,:) + (1-(1-factor)^2)*ward_img(n,m,:)) + imageOut(n,m,:)) / 2;
                            end
                        end
                    end
                case 2
                case 3
                case 4
                case 5
                case 6
                case 7
                case 8   
            end     
        end
    end
end

figure('Name', 'Sectored image'),imshow(edgeExpand);
figure('Name', 'Hybrid image'),imshow(imageOut);
figure('Name', 'Ward'),imshow(ward_img);
figure('Name', 'iCAM'),imshow(iCAM_img);