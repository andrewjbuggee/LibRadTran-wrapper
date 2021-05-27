%% --- Read Output Files from UVSPEC ---
% ======================================
% The purpose of this script is to run uvspec with the inputs specfied in
% by the user. The user will be required to specify the atmospheric
% composition, RTE solver, wavelength range, wavelength resolution, aerosol
% content, cloud content, and solar spectrum. The file created is a .inp 
% file, which will be fed into the command line to run uvspec.


clear all; close all;
% --- By Andrew J. Buggee ---
%% Creating the .INP file








%% Running the .INP file from the command line

% to run a .INP file from the command line, we run uvspec by pointing the
% command line to its full location. 

uvspec_folderName = ['/Users/andrewbuggee/Documents/CU-Boulder-ATOC/'...
                    'Hyperspectral-Cloud-Droplet-Retrieval-Research/',...
                    'LibRadTran/libRadtran-2.0.4/bin/'];
% using the function 'system' runs commans in the terminal window
[status,cmdout] = system([uvspec_folderName,'uvspec ',...
                  '<input.INP> output.OUT']);
                
                
                
                
                
                