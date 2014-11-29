function valOut = truncate(val)
if val < 0
    valOut = 0;
elseif val > 255
    valOut = 255;
else
    valOut = val;
end
end
    

