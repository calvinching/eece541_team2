function  color_LDR = color_correction_tonemapping(luminance_in, color_in, Y_LDR, sat_value)

% Y_LDR_1 = (Y_LDR / 255) .^ (2.2);
% color_LDR_1 = ((color_in ./ repmat(luminance_in, [1, 1, 3])) .^ gamma_value .* repmat(Y_LDR_1, [1, 1, 3])) .^ (1/2.2);
% %color_LDR_1 = (((color_in ./ repmat(luminance_in, [1, 1, 3]) - 1) * gamma_value + 1)  .* repmat(Y_LDR_1, [1, 1, 3])) .^ (1/2.2);
% color_LDR = uint8((color_LDR_1 * 255));
gamma_value = 1;

Y_LDR_1 = (double(Y_LDR) / 255) .^ (gamma_value);



luminance_in(find(luminance_in <= 0)) = min(min(luminance_in(find(luminance_in > 0)))); % To avoid the denominator being zero in the following calculation

for k = 1 : 3

      
        color_LDR_1 = ((color_in(:,:,k) ./ luminance_in) .^ sat_value .* Y_LDR_1) .^ (1/gamma_value);
        %color_LDR_1 = (((color_in ./ repmat(luminance_in, [1, 1, 3]) - 1) * gamma_value + 1)  .* repmat(Y_LDR_1, [1, 1, 3])) .^ (1/2.2);
        color_LDR(:,:,k) = uint8((color_LDR_1 * 255));
        
end