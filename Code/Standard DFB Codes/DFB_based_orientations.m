%%
% DFB based multiscale approach
function [FinalOrientationImage]=DFB_based_orientations(im)
clc;
R=double(im);
nr=size(R,1);
nc=size(R,2);
n=16; % for overlap case
angle=zeros(1,n);
t=[81 64 49 36  25  16  9 4 1];

WeightMatrix=zeros(nr,nc,size(t,2));
R=im2double(R);
[band,angle]=steve_16band_directional_filterbank(R);

 orientation=zeros(nr,nc,size(t,2));
 energy_band=zeros(nr,nc,n);
    for index=1:size(t,2)
      h=discreteGaussian(t(index));  
      for i=1:n
        image=band(:,:,i);
        Mean_image=imfilter(image,h,'conv','same','replicate');
        energy_band(:,:,i)= imfilter((image-Mean_image).^2,h,'conv','same','replicate');
      end
       % we will now do linear combination
    sum_energy=sum(energy_band,3)+eps;
    final_x=zeros(size(R));
    final_y=zeros(size(R));
    newWeightMatrix=zeros(size(R));
    for i=1:n
        final_x =final_x+((energy_band(:,:,i))./sum_energy).*sin(2*angle(i));
        final_y =final_y+((energy_band(:,:,i))./sum_energy).*cos(2*angle(i));
        newWeightMatrix= newWeightMatrix + ((energy_band(:,:,i).^3)./(sum_energy.^2));
    end
   OrientationImage(:,:,index)= 0.5*atan2(final_x,final_y);
   WeightMatrix(:,:,index)= newWeightMatrix;
    end
   final_x=0;
   final_y=0;
   sum_matrix=sum(WeightMatrix,3);
   for index=1:size(t,2)
       final_x=final_x+ (WeightMatrix(:,:,index)./sum_matrix).*sin(2*OrientationImage(:,:,index));
       final_y=final_y+ (WeightMatrix(:,:,index)./sum_matrix).*cos(2*OrientationImage(:,:,index));
   end
   FinalOrientationImage=0.5*atan2(final_x,final_y);
plotridgeorient(-FinalOrientationImage, 10, R);
end