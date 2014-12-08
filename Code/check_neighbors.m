function [ per ] = check_neighbors( im, row, col, neighbors )

sum = 0;
row_l = row-neighbors;
row_h = row+neighbors;
col_l = col-neighbors;
col_h = col+neighbors;
[num_rows, num_cols] = size(im);
if (row > 8)
    if (row_l < 9)
        row_l = 9;
    end
else
    if (row_l < 1)
        row_l = 1;
    end
end

if (row > 1073)
    if (row_h > num_rows)
        row_h = num_rows;
    end
else
    if (row_h > 1074)
        row_h = 1074;
    end
end

if (col > 8)
    if (col_l < 9)
        col_l = 9;
    end
else
    if (col_l < 1)
        col_l = 1;
    end
end

if (col > 1914)
    if (col_h > num_cols)
        col_h = num_cols;
    end
else
    if (col_h > 1914)
        col_h = 1914;
    end
end
for x=row_l:1:row_h
    for y=col_l:1:col_h
        if (x ~= row || y ~=col)
            sum = im(x,y) + sum;
        end
    end
end

max = (row_h-row_l+1)*(col_h-col_l+1) - 1;
per = double(sum)/double(max);


end

