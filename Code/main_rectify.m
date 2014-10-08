% Rectify a set of images
% August 18, 2010


clear all
close all

hdr_dir = 'C:\Workspace\Source\3D\HDR_3D\';
tmo_dir = 'results\20100816_LDRImages\';
store_dir = 'results\20100819_RectifiedLDR_85PCT\';
image_name_array = {'ICICS', 'MeetingTable', 'LabWindow', 'Bulletin'};
tmo_name_array = {'_reinhard02_global', '_reinhard02_local', '_reinhard05', ...
    '_durand02_c4', '_fattal02_a1_b08_s1', '_mantiuk08', '_drago03',...
    '_iCAM', '_mai09', '_single'};

for image_index = length(image_name_array)
    for tmo_index = length(tmo_name_array)
        if tmo_index ~= length(tmo_name_array)
            imL_dir = [tmo_dir, image_name_array{image_index}, '_left_sm', tmo_name_array{tmo_index}, '.png'];       
            imR_dir = [tmo_dir, image_name_array{image_index}, '_right_sm', tmo_name_array{tmo_index}, '.png'];
        else
            imL_dir = [tmo_dir, image_name_array{image_index}, '_left_sm', tmo_name_array{tmo_index}, '.JPG'];       
            imR_dir = [tmo_dir, image_name_array{image_index}, '_right_sm', tmo_name_array{tmo_index}, '.JPG'];
        end
            
        imL = imread(imL_dir);
        imR = imread(imR_dir);
        [imLc, imRc] = rectify_image_func(imL, imR, store_dir, [image_name_array{image_index}, tmo_name_array{tmo_index}]);
    end
end
        