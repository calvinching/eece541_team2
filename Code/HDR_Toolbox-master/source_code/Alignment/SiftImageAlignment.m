function imgOut = SiftImageAlignment(img1, img2, maxIterations)
%
%       l=lum(img)
%
%       This function calculates the luminance
%
%
%       input:
%           img1: target image
%           img2: image to align to img1
%           maxIterations: number of iterations for RANSAC (typically 32-100) 
%
%       output:
%           imgOut: img2 aligned to img1 using a homography
%
%
%     This code is written by Francesco Banterle, based upon the 
%     "SIFT_MOSAIC" example from the VL Fleat library by Andrea Vedaldi
%     and Brian Fulkerson (starting team), and the whole VL Feat team.
%     For more details please visit the website of the package:
%                   http://www.vlfeat.org/
%     
%   BSD license:
%       Copyright (C) 2007-11, Andrea Vedaldi and Brian Fulkerson
%       Copyright (C) 2012-13, The VLFeat Team
%       All rights reserved.
% 
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are
%   met:
%   1. Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%   2. Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in the
%      documentation and/or other materials provided with the
%      distribution.
% 
%    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
%   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
%   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
%   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
%   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
%   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%

if(~exist('vl_imwbackward')||~exist('vl_colsubset')||~exist('vl_sift')||~exist('vl_ubcmatch'))
    error('This function needs VL Feat. Please download it from http://www.vlfeat.org/');
end

if(~exist('maxIterations','var'))
    maxIterations = 64;
end

if(maxIterations<1)
    maxIterations = 64;
end

%converting into luminance
ratio_2_1 = RemoveSpecials(img2./img1);
scale = mean(ratio_2_1(:));
img1 = ClampImg(img1*scale,0.0,1.0);

try
    im1g = single(ColorToGreyFusion(img1));
    im2g = single(ColorToGreyFusion(img2));
catch e
    disp(e);
    im1g = single(lum(img1));
    im2g = single(lum(img2));
end

%SIFT matches
[f1,d1] = vl_sift(im1g) ;
[f2,d2] = vl_sift(im2g) ;

[matches, scores] = vl_ubcmatch(d1,d2) ;

numMatches = size(matches,2) ;

X1 = f1(1:2,matches(1,:)) ; X1(3,:) = 1 ;
X2 = f2(1:2,matches(2,:)) ; X2(3,:) = 1 ;


% RANSAC with homography model
%clear H score ok ;
for t = 1:maxIterations
  % estimate homograpyh
  subset = vl_colsubset(1:numMatches, 4) ;
  A = [] ;
  for i = subset
    A = cat(1, A, kron(X1(:,i)', vl_hat(X2(:,i)))) ;
  end
  [U,S,V] = svd(A) ;
  H{t} = reshape(V(:,9),3,3) ;

  % score homography
  X2_ = H{t} * X1 ;
  du = X2_(1,:)./X2_(3,:) - X2(1,:)./X2(3,:) ;
  dv = X2_(2,:)./X2_(3,:) - X2(2,:)./X2(3,:) ;
  ok{t} = (du.*du + dv.*dv) < 4 ;
  score(t) = sum(ok{t}) ;
end

[score, best] = max(score) ;
H = H{best} ;
ok = ok{best} ;

% Optional refinement
function err = residual(H)
    u = H(1) * X1(1,ok) + H(4) * X1(2,ok) + H(7) ;
    v = H(2) * X1(1,ok) + H(5) * X1(2,ok) + H(8) ;
	d = H(3) * X1(1,ok) + H(6) * X1(2,ok) + 1 ;
	du = X2(1,ok) - u ./ d ;
	dv = X2(2,ok) - v ./ d ;
	err = sum(du.*du + dv.*dv) ;
end

if(exist('fminsearch') == 2)
    H = H / H(3,3) ;
    opts = optimset('Display', 'none', 'TolFun', 1e-8, 'TolX', 1e-8) ;
    H(1:8) = fminsearch(@residual, H(1:8)', opts) ;
else
    disp('Refinement disabled as fminsearch was not found.') ;
end

%Applying homography H
ur = 1:size(img1,2);
vr = 1:size(img1,1);
[u,v] = meshgrid(ur,vr) ;

z_ =  H(3,1) * u + H(3,2) * v + H(3,3) ;
u_ = (H(1,1) * u + H(1,2) * v + H(1,3)) ./ z_ ;
v_ = (H(2,1) * u + H(2,2) * v + H(2,3)) ./ z_ ;
imgOut = RemoveSpecials(vl_imwbackward(img2,u_,v_));

end