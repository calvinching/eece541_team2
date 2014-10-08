function frameOut = BoitardTMOv_frame(frame, max_log_mean_HDR, max_log_mean_LDR, tmo_operator, tmo_zeta)
%
%
%       frameOut = BoitardTMOv_frame(frame, max_hm_HDR, max_hm_LDR, tmo_operator)
%
%
%       Input:
%           -frame: input HDR frame
%           -max_log_mean_HDR: the maximum logarithmic mean in HDR of the
%           video
%           -max_log_mean_LDR: the maximum logarithmic mean in LDR of the
%           video
%           -tmo_operator: the tone mapping operator to use
%           -tmo_zeta: it is the "Minscale" parameter of the original paper,
%           please see Equation 8 of it.
%
%       Output:
%           -frameOut: the tone mapped frame
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
%
%     The paper describing this operator is:
%     "Temporal Coherency for Video Tone Mapping"
%     by R. Boitard, K. Bouatouch, R. Cozot, D. Thoreau, A. Gruson
%     Proc. SPIE 8499, Applications of Digital Image Processing XXXV
%
%     DOI: 10.1117/12.929600 
%
%     Link : http://people.irisa.fr/Ronan.Boitard/articles/2012/TCVTM2012.pdf
%

if(~exist('tmo_operator','var'))
    tmo_operator = @ReinhardTMO;
end

if(~exist('tmo_zeta','var'))
    tmo_zeta = 0.1;
end

%Tone mapping + Gamma encoding
frame_tmo = tmo_operator(frame);

k_f_HDR = logMean(lum(frame));
k_f_LDR = logMean(lum(frame_tmo));
scale = tmo_zeta + (k_f_HDR*max_log_mean_LDR)/(max_log_mean_HDR*k_f_LDR);

frameOut = (frame_tmo*scale);

end