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

function [status,inputSettings] = runUVSPEC(folderName,inputName,outputName)
%% ---- A Few Checks are Needed ----

if iscell(inputName)==true && iscell(outputName)==false
    error('inputName is a cell array, while outputName is not')
    
elseif iscell(inputName)==false && iscell(outputName)==true
    error('outputName is a cell array, while inputName is not')
    
elseif iscell(inputName)==true && iscell(outputName)==true
    if length(inputName)~=length(outputName)
        error('The number of input files doesns equal the number of output files')
    end
end



%% ----- Lets Read the input file -----

% Lets determine the rte_solver type

textFile = fileread([folderName,inputName]);

expr1 = '[^\n]*rte_solver [^\n]*';
expr2 = '[^\n]*umu [^\n]*';
expr3 = '[^\n]*phi [^\n]*';
expr4 = '[^\n]*sza [^\n]*';
expr5 = '[^\n]*phi0 [^\n]*';
expr6 = '[^\n]*zout [^\n]*';

match1 = regexp(textFile,expr1,'match'); % find rte_solver typ
match2 = regexp(textFile,expr2,'match'); % find consine of viewing angle vector
match3 = regexp(textFile,expr3,'match'); % find azimuth viewing angle vector
match4 = regexp(textFile,expr4,'match'); % find the solar zenith angle
match5 = regexp(textFile,expr5,'match'); % find the solar azimuth angle
match6 = regexp(textFile,expr6,'match'); % find the sensor altitude


index1 = find(match1{1}==' '); % find the spaces

index2_spaces = regexp(match2{1},'\s'); % find the spaces
index2_dots = regexp(match2{1},'[.]'); % Brackets treat the symbol literally. number of decimals tells us how many values there are in the vector

index3_spaces = regexp(match3{1},'\s'); % find the spaces
index3_dots = regexp(match3{1},'[.]'); % Brackets treat the symbol literally. number of decimals tells us how many values there are in the vector

index4_spaces = regexp(match4{1},'\s'); % find the spaces. There is only 1 value for the solar zenith angle

index5_spaces = regexp(match5{1},'\s'); % find the spaces. There is only 1 value per file for the solar azimuth

index6_spaces = regexp(match6{1},'\s'); % find the spaces. There is only 1 value per file for the solar azimuth



% determine the rte_solver type
rte_solver = match1{1}(index1(1)+1:index1(2)-1);

% determine the umu vector
umuStr = cell(1,length(index2_dots));

for ii = 1:length(index2_dots)
    umuStr{ii} = match2{1}(index2_spaces(ii)+1:index2_spaces(ii+1)-1);
end

umuVec = str2double(umuStr);

% determine the phi vector
phiStr = cell(1,length(index3_dots));

for ii = 1:length(index3_dots)
    phiStr{ii} = match3{1}(index3_spaces(ii)+1:index3_spaces(ii+1)-1);
end

phiVec = str2double(phiStr);

% find the solar zenith angle
sza = match4{1}(index4_spaces(1)+1:index4_spaces(2)-1);
sza = str2double(sza);

% find the solar azimuth angle
saz = match5{1}(index5_spaces(1)+1:index5_spaces(2)-1);
saz = str2double(saz);

% find the sensor altitude
zout = match6{1}(index6_spaces(1)+1:index6_spaces(2)-1);
zout = str2double(zout);


% Pull all input settings into a cell array
inputSettings{1} = rte_solver;
inputSettings{2} = umuVec;
inputSettings{3} = phiVec;
inputSettings{4} = sza;
inputSettings{5} = saz;
inputSettings{6} = zout;

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


% First we need to determine how many files we need to run

if iscell(inputName)==true
    numFiles2Run = length(inputName);
elseif ischar(inputName)==true
    numFiles2Run = 1;
else
    error('I dont understand the input file')
end




% --- Now we Can Run the Files ----


% --- Point to locaiton of uvspec program ---
uvspec_folderName = ['/Users/andrewbuggee/Documents/CU-Boulder-ATOC/'...
    'Hyperspectral-Cloud-Droplet-Retrieval-Research/',...
    'LibRadTran/libRadtran-2.0.4/bin/'];

% using the function 'system' runs commans in the terminal window
cmnd1 = ['cd ', folderName];



if numFiles2Run==1
    
    
    % cmnd2 = [uvspec_folderName,'uvspec ',...
    %            '< ',inputName,' > ', outputName];
    
    cmnd2 = ['(',uvspec_folderName,'uvspec ',...
        '< ',inputName,' > ', outputName,')>& errMsg.txt'];
    % a successful command will return a status of 0
    % an unsuccessful command will return a status of 1
    
    
    
    [status] = system([cmnd1, ' ; ', cmnd2]);
    if status ~= 0
        error(['Status returned value of ',num2str(status)])
    end
    
elseif numFiles2Run>1
    
    
    for ii = 1:numFiles2Run
        
        
        % cmnd2 = [uvspec_folderName,'uvspec ',...
        %            '< ',inputName,' > ', outputName];
        
        cmnd2 = ['(',uvspec_folderName,'uvspec ',...
            '< ',inputName{ii},' > ', outputName{ii},')>& errMsg.txt'];
        % a successful command will return a status of 0
        % an unsuccessful command will return a status of 1
        
        [status] = system([cmnd1, ' ; ', cmnd2]);
        if status ~= 0
            error(['Status returned value of ',num2str(status)])
        end
    end
    
else
    
    error('I Dont understand the file names you are trying to run')
    
end



end






