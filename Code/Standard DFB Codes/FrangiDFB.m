function [outIm,whatScale,Direction] = FrangiDFB(I, options)
% This function FRANGIFILTER2D uses the eigenvectors of the Hessian to
% compute the likeliness of an image region to vessels, according
% to the method described by Frangi:2001 (Chapter 2).
%
% [J,Scale,Direction] = FrangiFilter2D(I, Options)
%
% inputs,
%   I : The input image (vessel image)
%   Options : Struct with input options,
%       .FrangiScaleRange : The range of sigmas used, default [1 8]
%       .FrangiScaleRatio : Step size between sigmas, default 2
%       .FrangiBetaOne : Frangi correction constant, default 0.5
%       .FrangiBetaTwo : Frangi correction constant, default 15
%       .BlackWhite : Detect black ridges (default) set to true, for
%                       white ridges set to false.
%       .verbose : Show debug information, default true
%
% outputs,
%   J : The vessel enhanced image (pixel is the maximum found in all scales)
%   Scale : Matrix with the scales on which the maximum intensity 
%           of every pixel is found
%   Direction : Matrix with directions (angles) of pixels (from minor eigenvector)   
%
% Example,
%   I=double(imread ('vessel.png'));
%   Ivessel=FrangiFilter2D(I);
%   figure,
%   subplot(1,2,1), imshow(I,[]);
%   subplot(1,2,2), imshow(Ivessel,[0 0.25]);
%
% Written by Marc Schrijver, 2/11/2001
% Re-Written by D.Kroon University of Twente (May 2009)

defaultoptions = struct('FrangiScaleRange', [1 10], 'FrangiScaleRatio', 2, 'FrangiBetaOne', 0.5, 'FrangiBetaTwo', 15, 'verbose',true,'BlackWhite',true);

% Process inputs
if(~exist('options','var')), 
    options=defaultoptions; 
else
    tags = fieldnames(defaultoptions);
    for i=1:length(tags)
         if(~isfield(options,tags{i})),  options.(tags{i})=defaultoptions.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(options))), 
        warning('FrangiFilter2D:unknownoption','unknown options found');
    end
end

sigmas=options.FrangiScaleRange(1):options.FrangiScaleRatio:options.FrangiScaleRange(2);
sigmas = sort(sigmas, 'ascend');

beta  = 2*options.FrangiBetaOne^2;
c     = 2*options.FrangiBetaTwo^2;

% Make matrices to store all filterd images
ALLfiltered=zeros([size(I) length(sigmas)]);
ALLangles=zeros([size(I) length(sigmas)]);
 

WeightMatrix=zeros(size(I,1),size(I,2),size(sigmas,2));
R=im2double(I);
disp(['computing directional images (n = ' num2str(2^4) ') ...']);
t = ddfb_4_stages(R,4,64); %directional filter bank

n = size(t,3); %number of directional images
for i=1:n
    angle(i) = (pi/4+ (mod(i-1,n) + 0.5)*pi/n);
end

% [band,angle]=steve_16band_directional_filterbank(R);
% n=16; % no of band
 
% Frangi filter for all sigmas
for i = 1:length(sigmas),
    % Show progress
    if(options.verbose)
        disp(['Current Frangi Filter Sigma: ' num2str(sigmas(i)) ]);
    end
    
   
      h=discreteGaussian(sigmas(i));
      for K=1:n
        image=mat2gray(t(:,:,K));
        Mean_image=imfilter(image,h,'conv','same','replicate');
        energy_band(:,:,K)= imfilter((image-Mean_image).^2,h,'conv','same','replicate');
      end
       % we will now do linear combination
    sum_energy=sum(energy_band,3)+eps;
    
    final_x=zeros(size(R));
    
    newWeightMatrix=zeros(size(R));
   
   for K=1:n
        % Make 2D hessian
       [Dxx,Dxy,Dyy] = Hessian2D(mat2gray(t(:,:,K))*255.0,sigmas(i));
    
       % Correct for scale
       Dxx = (sigmas(i)^2)*Dxx;
       Dxy = (sigmas(i)^2)*Dxy;
       Dyy = (sigmas(i)^2)*Dyy;
   
    %Calculate the eigen values and eigen vectors through directional
    %filter bank
    
    mu1band = ((cos(angle(K))).^2).*Dxx + sin(2*angle(K)).*Dxy...
                    + (sin(angle(K)).^2).*Dyy;
    mu2band = ((sin(angle(K))).^2).*Dxx - sin(2*angle(K)).*Dxy...
                    + (cos(angle(K)).^2).*Dyy;
                
        mymu1band=abs(mu1band);
        mymu2band=abs(mu2band);
        
        % Sort eigen values by absolute value abs(Lambda1)<abs(Lambda2)
       check=mymu1band>mymu2band;

       Lambda2=mu1band; Lambda2(check)=mu2band(check);
       Lambda1=mu2band; Lambda1(check)=mu1band(check);
       % Compute some similarity measures
       Lambda1(Lambda1==0) = eps;
       Rb = (Lambda2./Lambda1).^2;
       S2 = Lambda1.^2 + Lambda2.^2;
       band_energy(:,:,K)=(exp(-Rb/beta) .*(ones(size(I))-exp(-S2/c)));
%        energy_band(:,:,K)= ((abs(Lambda2)-abs(Lambda1))./(abs(Lambda2)+abs(Lambda1))).^2;
   end
   sum_energy=sum(energy_band,3)+eps;
   for K=1:n
    % Compute the output image
%         myfiltered(:,:,K)=(exp(-Rb/beta) .*(ones(size(I))-exp(-S2/c)));
        final_x =final_x+((energy_band(:,:,K))./sum_energy).*band_energy(:,:,K);
        
        newWeightMatrix= newWeightMatrix + ((energy_band(:,:,K).^3)./(sum_energy.^2));
    end
     
   Filtered_output(:,:,i)= final_x;
   WeightMatrix(:,:,i)= newWeightMatrix;
   
end
  
   final_x=zeros(size(R));
   
   sum_matrix=sum(WeightMatrix,3);
   for i=1:length(sigmas)
       final_x=final_x+ (WeightMatrix(:,:,i)./sum_matrix).*Filtered_output(:,:,i);
   end
   outIm=max(Filtered_output,[],3); 
      
% %     Ifiltered = exp(-Rb/beta) .*(ones(size(I))-exp(-S2/c));
% %     
% %     % see pp. 45
% %     if(options.BlackWhite)
% %         Ifiltered(Lambda1<0)=0;
% %     else
% %         Ifiltered(Lambda1>0)=0;
% %     end
%     % store the results in 3D matrices
%     ALLfiltered(:,:,i) = Ifiltered;
% %     ALLangles(:,:,i) = angles;
end

% Return for every pixel the value of the scale(sigma) with the maximum 
% output pixel value
% if length(sigmas) > 1,
%     [outIm,whatScale] = max(ALLfiltered,[],3);
%     outIm = reshape(outIm,size(I));
%     if(nargout>1)
%         whatScale = reshape(whatScale,size(I));
%     end
%     if(nargout>2)
%         Direction = reshape(ALLangles((1:numel(I))'+(whatScale(:)-1)*numel(I)),size(I));
%     end
% else
%     outIm = reshape(ALLfiltered,size(I));
%     if(nargout>1)
%             whatScale = ones(size(I));
%     end
%     if(nargout>2)
%         Direction = reshape(ALLangles,size(I));
%     end
% end