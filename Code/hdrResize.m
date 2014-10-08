% Resize HDR images

function hdrResize(hdr_file, store_file, rate)

cmd_line = sprintf( '%spfsin ''%s'' | pfssize -r %f | pfsout ''%s'' %s', pfs_shell(), hdr_file, rate, store_file, pfs_shell( 1 ) );
fid = pfspopen( cmd_line, 'r' );
pin = pfsopen( fid );