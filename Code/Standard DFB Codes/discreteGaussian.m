function h = discreteGaussian(scale)
%discreteGaussian will compute discrete gaussian with two dimension
size=floor(-4*sqrt(scale)):ceil(4*sqrt(scale));
g=besseli(size,scale,1);
h=g'*g;
h=h./sum(sum(h));
end

