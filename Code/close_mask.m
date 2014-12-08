function [ out_mask, num ] = close_mask( edge_mask )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[Row, Col] = size(edge_mask);
num = 0;
for j=1:1:Col
    for i=1:1:Row
        if (edge_mask(i,j) == 0 && i > 4 && j > 4 && i+4 < Row && j+4 < Col)
            sum = 0;
            for x=i-4:1:i+4
                for y=j-4:1:j+4
                    sum = edge_mask(x,y) + sum;
                end
            end
            if (sum > 40)
                edge_mask(i,j) = 1;
                num = num + 1;
            end
        end
    end
end
out_mask = edge_mask;
end

