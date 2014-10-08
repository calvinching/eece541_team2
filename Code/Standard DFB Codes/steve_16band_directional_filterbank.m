function [result,angle]=steve_16band_directional_filterbank(xx)

%%%% We try to develop directional filterband using imrotate
% steve image processing block
% design a 16 band filterbank
for i=1:16
    if i==1
      [f1, f2] = freqspace(101, 'meshgrid');
      theta = cart2pol(f1, f2);
      Hdspecial = (theta >= (i-1)*pi/16 & (theta<pi/16+(i-1)*pi/16)) | (theta <= (-15*pi/16+(i-1)*pi/16) & (theta >= -pi+(i-1)*pi/16));
      Hdspecial=double(Hdspecial);
%       mesh(f1, f2, double(Hdspecial))
%       title('Ideal frequency response')
      h6 = fwind1(Hdspecial, hamming(31));
      h6=real(h6);
     % h6=h6./sum(sum(h6));

%       freqz2(h6)
%       title('Designed filter frequency response')

     result(:,:,i) = mat2gray(imfilter(xx, real(h6),'conv','same','replicate'));
     figure,imshow(result(:,:,i),[]);
    else
        h6=imrotate(h6,11.25,'bicubic');
%         freqz2(h6)
%       title('Designed filter frequency response')

     result(:,:,i) = mat2gray(imfilter(xx, real(h6),'conv','same','replicate'));
     figure,imshow(result(:,:,i),[]);
    end
end

angle(1,1)=pi/2;
for i=2:16
    angle(1,i)=angle(1,i-1)+(pi/16);
end





