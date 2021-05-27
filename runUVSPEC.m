%% --- Run Intput Files with UVSPEC ---
% ======================================
% The purpose of this script is to run uvspec with the input files specfied
% by the user. The user will be required to provide to folder location of
% the input file, and the input file name. The user will also need to 
% provide the output file name. This output file will be saved in the 
% same folder as the input file. The input file will be fed into the 
% command line in order to run uvspec.



% --- By Andrew J. Buggee ---
%% Creating the .INP file

function [status,cmdout] = runUVSPEC(folderName,inputName,outputName)




% folderName = ['/Users/andrewbuggee/Documents/CU-Boulder-ATOC/',...
%     'Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/',...
%     'libRadtran-2.0.4/examples/'];
% inputName = 'UVSPEC_CLEAR.INP';
% 
% % --- Create output name ---
% outputName = 'outputTest3.OUT';

%% Running the .INP file from the command line

% to run a .INP file from the command line, we run uvspec by pointing the
% command line to its full location. AND the command line directory must be
% in the folder where the file you are running sits. For example, if the
% file you wish to run lives in the folder: directory/folder/runMe.file
% and the program runnning the file is in the folder:
% directory/program/fancyProgram then the code in the command line to run 
% this file is:
%
% cd directory/folder/
% directory/program/fancyProgram < runMe.file > output.OUT


% --- Point to locaiton of uvspec program ---
uvspec_folderName = ['/Users/andrewbuggee/Documents/CU-Boulder-ATOC/'...
                    'Hyperspectral-Cloud-Droplet-Retrieval-Research/',...
                    'LibRadTran/libRadtran-2.0.4/bin/'];
                
                
% using the function 'system' runs commans in the terminal window
cmnd1 = ['cd ', folderName];


% cmnd2 = [uvspec_folderName,'uvspec ',...
%            '< ',inputName,' > ', outputName];
       
cmnd2 = ['(',uvspec_folderName,'uvspec ',...
           '< ',inputName,' > ', outputName,')>& errMsg.txt'];
% a successful command will return a status of 0
% an unsuccessful command will return a status of 1
[status,cmdout] = system([cmnd1, ' ; ', cmnd2]);


end

                
                
                
                
                
                