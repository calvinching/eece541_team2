function [imgOut,lights]=UniformSampling(img,nlights,falloff)
%
%
%        [imgOut,lights]=UniformSampling(img,nlights,falloff)
%
%
%        Input:
%           -img: an environment map in the latitude-longitude mapping
%           -nlights: the number of samples to generate
%           -falloff: a flag. If it is set 1, it means that fall-off will
%                     be taken into account
%
%        Output:
%           -imgOut: an image with sampled points
%           -lights: a list of directional lights
%
%     Copyright (C) 2013  Francesco Banterle
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

if(~exist('nlights','var'))
    nlights = 1024;
end

if(~exist('falloff','var'))
    falloff = 0;
end

%falloff compensation
if(falloff)
    img = FallOffEnvMap(img);
end

%Global variables initialization
L=lum(img);
[r,c] = size(L);
n = round(sqrt(nlights));

c1 = ceil(c/n);
r1 = ceil(r/n);

limitSize = 2;

if((c1<limitSize)||(r1<limitSize))
    error('Error');
end

lights = [];
for i=1:r1
    yMin = (i-1)*n+1;
    yMax = min(i*n,r);
    
    for j=1:c1
        xMin = (j-1)*n+1;
        xMax = min(j*n,c);
        
        lights = [lights, CreateLight(xMin,xMax,yMin,yMax,L,img)];
    end
end

imgOut = GenerateLightMap(lights,c,r);

end