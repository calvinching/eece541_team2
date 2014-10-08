function [Lambda1,Lambda2,Ix,Iy]=eig2image(Dxx,Dxy,Dyy)
% This function eig2image calculates the eigen values from the
% hessian matrix, sorted by abs value. And gives the direction
% of the ridge (eigenvector smallest eigenvalue) .
% 
% [Lambda1,Lambda2,Ix,Iy]=eig2image(Dxx,Dxy,Dyy)
%

%
% | Dxx  Dxy |
% |          |
% | Dxy  Dyy |


% Compute the eigenvectors of J, v1 and v2
tmp = sqrt((Dxx - Dyy).^2 + 4*Dxy.^2);
v2x = 2*Dxy; v2y = Dyy - Dxx + tmp;

% Normalize
mag = sqrt(v2x.^2 + v2y.^2); i = (mag ~= 0);
v2x(i) = v2x(i)./mag(i);
v2y(i) = v2y(i)./mag(i);

% The eigenvectors are orthogonal
v1x = -v2y; 
v1y = v2x;

mu1band = ((cos(tmp)).^2).*Dxx + sin(2*tmp).*Dxy...
                    + (sin(tmp).^2).*Dyy;
    mu2band = ((sin(tmp)).^2).*Dxx - sin(2*tmp).*Dxy...
                    + (cos(tmp).^2).*Dyy;
                
        mymu1band=abs(mu1band);
        mymu2band=abs(mu2band);
        
        % Sort eigen values by absolute value abs(Lambda1)<abs(Lambda2)
       check=mymu1band>mymu2band;

       Lambda2=mu1band; Lambda2(check)=mu2band(check);
       Lambda1=mu2band; Lambda1(check)=mu1band(check);

Ix=v1x; Ix(check)=v2x(check);
Iy=v1y; Iy(check)=v2y(check);




