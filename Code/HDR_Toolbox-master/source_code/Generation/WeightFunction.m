function weight = WeightFunction(img, weight_type)
%
%       weight = WeightFunction(img, weight_type)
%
%
%        Input:
%           -img: input LDR image in [0,1]
%           -weight_type:
%               - 'all': weight is set to 1
%               - 'hat': hat function 1-(2x-1)^12
%               - 'Deb97': Debevec and Malik 97 weight function
%               - 'Akyuz': Akyuz and Reinhard
%               - 'Gauss': Gaussian (mu = 0.5, sigma=0.15) 
%
%        Output:
%           -weight: the output weight function for a given LDR image
%
%     Copyright (C) 2011  Francesco Banterle
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

switch weight_type
    case 'all'
        weight = ones(size(img));
        
    case 'Akyuz'
        weight = ones(size(img));
        t1 = 200/255;
        t2 = 250/255;
        t3 = 50 /255;
        weight(img>=t2) = 0;        
        tmp  = 1 - (t2-img)/t3;
        tmp2 = 1 - 3*tmp.^2 + 2*tmp.^3;      
        weight(img >= t1 & img <= t2) = tmp2(img >= t1 & img <= t2);
        
    case 'Gauss'
        weight = exp(-(img-0.5).^2/(2*(0.15)^2));
        
    case 'hat'
        weight = 1 - (2*img-1).^12;
        
    case 'Deb97'
        Zmin = 0.0;
        Zmax = 1.0;
        tr = (Zmin+Zmax)/2;
        indx1 = find (img<=tr);
        indx2 = find (img>tr);
        weight = zeros(size(img));
        weight(indx1) = img(indx1) - Zmin;
        weight(indx2) = Zmax - img(indx2);
        weight(weight<0) = 0;
        weight = weight/max(weight(:));
        
    otherwise 
        weight = 1;
end

end