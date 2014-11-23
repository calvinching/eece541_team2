function imageOut = rgblaplacian(f)

f=im2double(f);
r=f(:,:,1);
g=f(:,:,2);
b=f(:,:,3);
[m n]=size(r);
for i=1:m
    for j=1:n
        ip=i+1;
        im=i-1;
        jm=j-1;
        jp=j+1;
        if(im<1)
            im=i;
        elseif (ip>m)
            ip=i;
        end
        if(jm<1)
            jm=j;
        elseif (jp>n)
            jp=j;
        end
        rt(i,j)=-4*r(i,j)+ 1*(r(i,jm)+r(i,jp)+r(ip,j)+r(im,j));
        gt(i,j)=-4*g(i,j)+ 1*(g(i,jm)+g(i,jp)+g(ip,j)+g(im,j));
        bt(i,j)=-4*b(i,j)+ 1*(b(i,jm)+b(i,jp)+b(ip,j)+b(im,j));
       end
end
rt=r-rt;
gt=g-gt;
bt=b-bt;
T=cat(3,rt,gt,bt);
imageOut = T;
imshow(f),title('Original Image');
figure, imshow(T),title('Sharpened Image');