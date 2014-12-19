README

- Install MATLAB
- Setup MATLAB so the HDR_Toolbox-master directory (and subdirectories) are in the MATLAB build path
- There are two main files:
    - hybrid_main.m:
        - Main loop that reads each .hdr frame and calls the function to tone map it.
        - Also responsible for stitching the frames into a video
    - hybrid_tmo.m:
        - Main algorithm code
- Run hybrid_main.m (not hybrid_tmo.m)
- The rest are either helper functions or prototyping code that is not used in final solution
