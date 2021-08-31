%% --- Read Output Files from MIE ---
% ======================================
% The purpose of this script is to read the data output from the output
% file created by mie. The code will determine the headers for each
% column of data, and the numerical values. Headers will be stored in the
% first row of a cell array. The data will be stored in the second row of
% the cell array.


% TO-DO:
%   1) The outputs are different if we choose to output transmittance or
%   transmissivity. What are the headers?

%   2) Test to see if the new structure writing works with multiple files.



% --- By Andrew J. Buggee ---
%% --- Read in Files ---

function [dataStruct,headers] = readMIE(path,fileName)

% How many files do we need to read?

if iscell(fileName)==true
    numFiles2Read = length(fileName);
elseif ischar(fileName)==true
    numFiles2Read = 1;
else
    error('I dont understand the input file')
end

% [fileName,path] = uigetfile('.txt');
delimeter = ' ';
headerLine = 0; % 0 if no header

data = [];

if numFiles2Read==1
    data = importdata([path,fileName,'.OUT'],delimeter,headerLine);
    
elseif numFiles2Read>1
    
    for ii = 1:numFiles2Read
        
        data = cat(3,data,importdata([path,fileName{ii},'.OUT'],delimeter,headerLine));
        
    end
    
else
    
    error('There is something wrong with the number of files im supposed to read')
    
end

%% -- If there is a size distribution, we must remove the fit values --

% There is a non-homogenous size distribution if there are nan values in
% the final column of our data matrix

indexNan = isnan(data(:,end));

if sum(indexNan)>0
    
    % remove rows with nans
    data(indexNan,:) = [];
    
else
    
end


%% --- Converstion to a Structure ---


% we want an array ouput of the irradiance and radiance data for wasy
% analysis, and we want a structure output for easy manipulation on the fly



headers = cell(1,8);
headers{1} = 'wavelength';
headers{2} = 'refrac_real';
headers{3} = 'refrac_imag';
headers{4} = 'Qext';
headers{5} = 'ssa';
headers{6} = 'asymParam';
headers{7} = 'spike';
headers{8} = 'pmon';





% and now we'll create the structure
% we'll start by creating the wavelength vector



if numFiles2Read==1
    % if we have to zenith view angles, then only irradiance is
    % calculated
    
    if size(data,2) == 7
        
        dataStruct = struct(headers{1},data(:,1),...
            headers{2},data(:,2),headers{3},data(:,3),...
            headers{4},data(:,4),headers{5},data(:,5),...
            headers{6},data(:,6),headers{1,7},data(:,7));
        
    elseif size(data,2) == 8
        
        dataStruct = struct(headers{1},data(:,1),...
            headers{2},data(:,2),headers{3},data(:,3),...
            headers{4},data(:,4),headers{5},data(:,5),...
            headers{6},data(:,6),headers{1,7},data(:,7),...
            headers{1,8},data(:,8));
        
        
    end
    
    
    
    
    
    
    
    
elseif numFiles2Read>1
    dataStruct = struct(headers{1,1},reshape(data(:,1,:),[],numFiles2Read),...
        headers{1,2},reshape(data(:,2,:),[],numFiles2Read),headers{1,3},...
        reshape(data(:,3,:),[],numFiles2Read),headers{1,4},...
        reshape(data(:,4,:),[],numFiles2Read),headers{1,5},...
        reshape(data(:,5,:),[],numFiles2Read),headers{1,6},...
        reshape(data(:,6,:),[],numFiles2Read),headers{1,7},...
        reshape(data(:,7,:),[],numFiles2Read),headers{1,8},...
        reshape(data(:,8,:),[],numFiles2Read));
end








end

