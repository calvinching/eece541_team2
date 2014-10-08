function lin_fun = ComputeCRF(stack, stack_exposure, nSamples)
%
%       lin_fun = ComputeCRF(stack, stack_exposure, nSamples)
%
%       This function computes camera response function using Debevec and
%       Malik method.
%
%        Input:
%           -stack: a stack of LDR images;
%           -stack_exposure: an array containg the exposure time of each
%           image. Time is expressed in second (s).
%           -nSamples: number of samples for computing the CRF
%
%        Output:
%           -lin_fun: the inverse CRF
%
%     Copyright (C) 2014  Francesco Banterle
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

if(~exist('nSamples', 'var'))
    nSamples = 1000;
end

if(isempty(stack))
    error('stack cannot be empty!');
end

if(isempty(stack_exposure))
    error('stack_exposure cannot be empty!');
end

%we need values to be in [0,255]!
maxStack = max(stack(:));
if(maxStack<=(1.0+1e-9))
    stack = ClampImg(round(stack * 255),0,255);
end   

col = size(stack, 3);

%Weight function
W = WeightFunction(0:(1/255):1,'Deb97');

%stack sub-sampling
stack_hist = ComputeLDRStackHistogram(stack);
stack_samples = GrossbergSampling(stack_hist, nSamples);

%recovering the CRF
lin_fun = zeros(256, col);
log_stack_exposure = log(stack_exposure);

for i=1:col
    g = gsolve(stack_samples(:,:,i),log_stack_exposure,10,W);
    g = exp(g);
    lin_fun(:,i) = (g/max(g));
end

end