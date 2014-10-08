% Tone-map images using different TMOs
% August 13th, 2010

clear all
close all

hdr_dir = 'C:\Workspace\Source\3D\HDR_3D\';
store_dir = 'results\20100816_LDRImages\';
image_name_array = {'ICICS_left', 'ICICS_right', 'MeetingTable_left', 'MeetingTable_right',...
    'LabWindow_left', 'LabWindow_right', 'Bulletin_left', 'Bulletin_right'};

run_reinhard02_global = 0;
run_reinhard02_local  = 0;
run_reinhard05        = 0;
run_durand02          = 0;
run_fattal02          = 0;
run_mantiuk08         = 0;
run_drago03           = 0;
run_iCAM              = 0;
run_mai09             = 0;

num_image = 8;

for k = 1 : num_image
    
    image_name = [image_name_array{k}, '_sm'];
    hdr_file = [hdr_dir, image_name, '.hdr'];
    
    
%     % Resize
%     store_file = [hdr_dir, image_name_array{k}, '_sm.hdr'];
%     hdrResize(hdr_file, store_file, 0.5)
    
    % Reinhard02 Global
    if run_reinhard02_global == 1
        cmd_line = sprintf( '%spfsin ''%s'' | pfstmo_reinhard02 --key 0.18 | pfsgamma -g 2.2%s', pfs_shell(), hdr_file, pfs_shell( 1 ) );

        fid = pfspopen( cmd_line, 'r' );
        pin = pfsopen( fid );
        pin = pfsget( pin );
        % Color image img_tmo
        img_tmo = pfs_transform_colorspace( 'XYZ', pin.channels.X, pin.channels.Y, pin.channels.Z, 'RGB' );
        pfsclose( pin );
        pfspclose( fid );
        % Store image
        imwrite(img_tmo, [store_dir, image_name, '_reinhard02_global.png']);

        clear cmd_line img_tmo
    end

    % Reinhard02 Local
    if run_reinhard02_local == 1
        cmd_line = sprintf( '%spfsin ''%s'' | pfstmo_reinhard02 --key 0.18 --scales --range 8 | pfsgamma -g 2.2%s', pfs_shell(), hdr_file, pfs_shell( 1 ) );

        fid = pfspopen( cmd_line, 'r' );
        pin = pfsopen( fid );
        pin = pfsget( pin );
        % Color image img_tmo
        img_tmo = pfs_transform_colorspace( 'XYZ', pin.channels.X, pin.channels.Y, pin.channels.Z, 'RGB' );
        pfsclose( pin );
        pfspclose( fid );
        imwrite(img_tmo, [store_dir, image_name, '_reinhard02_local.png']);

        clear cmd_line img_tmo
    end
    
    
    % Reinhard05
    if run_reinhard05 == 1
        cmd_line = sprintf( '%spfsin ''%s'' | pfstmo_reinhard05 --brightness 0 | pfsgamma -g 2.2%s', pfs_shell(), hdr_file, pfs_shell( 1 ) );

        fid = pfspopen( cmd_line, 'r' );
        pin = pfsopen( fid );
        pin = pfsget( pin );
        % Color image img_tmo
        img_tmo = pfs_transform_colorspace( 'XYZ', pin.channels.X, pin.channels.Y, pin.channels.Z, 'RGB' );
        pfsclose( pin );
        pfspclose( fid );
        imwrite(img_tmo, [store_dir, image_name, '_reinhard05.png']);

        clear cmd_line img_tmo
    end
    
    
    % Durand02
    if run_durand02 == 1
        cmd_line = sprintf( '%spfsin ''%s'' |  pfstmo_durand02 -s 40 -r 0.4 -c 4 --original | pfsgamma -g 2.2%s', pfs_shell(), hdr_file, pfs_shell( 1 ) );

        fid = pfspopen( cmd_line, 'r' );
        pin = pfsopen( fid );
        pin = pfsget( pin );
        % Color image img_tmo
        img_tmo = pfs_transform_colorspace( 'XYZ', pin.channels.X, pin.channels.Y, pin.channels.Z, 'RGB' );
        pfsclose( pin );
        pfspclose( fid );
        imwrite(img_tmo, [store_dir, image_name, '_durand02_c4.png']);

        clear cmd_line img_tmo
    end
    
    % Gradient
    if run_fattal02 == 1
        cmd_line = sprintf( '%spfsin ''%s'' | pfstmo_fattal02 -a 1 -b 0.8 --saturation 1.0 | pfsgamma -g 2.2%s', pfs_shell(), hdr_file, pfs_shell( 1 ) );

        fid = pfspopen( cmd_line, 'r' );
        pin = pfsopen( fid );
        pin = pfsget( pin );
        % Color image img_tmo
        img_tmo = pfs_transform_colorspace( 'XYZ', pin.channels.X, pin.channels.Y, pin.channels.Z, 'RGB' );
        pfsclose( pin );
        pfspclose( fid );
        imwrite(img_tmo, [store_dir, image_name, '_fattal02_a1_b08_s1.png']);

        clear cmd_line img_tmo
    end
    
    % Mantiuk08
    if run_mantiuk08 == 1
        cmd_line = sprintf( '%spfsin ''%s'' | pfstmo_mantiuk08 | pfsgamma -g 2.2%s', pfs_shell(), hdr_file, pfs_shell( 1 ) );

        fid = pfspopen( cmd_line, 'r' );
        pin = pfsopen( fid );
        pin = pfsget( pin );
        % Color image img_tmo
        img_tmo = pfs_transform_colorspace( 'XYZ', pin.channels.X, pin.channels.Y, pin.channels.Z, 'RGB' );
        pfsclose( pin );
        pfspclose( fid );
        imwrite(img_tmo, [store_dir, image_name, '_mantiuk08.png']);

        clear cmd_line img_tmo
    end
    
    
    % Drago03
    if run_drago03 == 1
        cmd_line = sprintf( '%spfsin ''%s'' | pfstmo_drago03 -b 0.85 | pfsgamma -g 2.2%s', pfs_shell(), hdr_file, pfs_shell( 1 ) );

        fid = pfspopen( cmd_line, 'r' );
        pin = pfsopen( fid );
        pin = pfsget( pin );
        % Color image img_tmo
        img_tmo = pfs_transform_colorspace( 'XYZ', pin.channels.X, pin.channels.Y, pin.channels.Z, 'RGB' );
        pfsclose( pin );
        pfspclose( fid );
        imwrite(img_tmo, [store_dir, image_name, '_drago03.png']);

        clear cmd_line img_tmo
    end
    
    % Fairchild iCAM
    if run_iCAM == 1
        
        img_tmo = myiCAM_sub(hdr_file);
        imwrite(img_tmo, [store_dir, image_name, '_iCAM.png']);

        clear img_tmo        
    end
    
    % Mai09
    if run_mai09 == 1
        img_tmo = Mai09_sub(hdr_file);
        imwrite(img_tmo, [store_dir, image_name, '_mai09.png']);

        clear img_tmo        
    end
        
    
    
end
