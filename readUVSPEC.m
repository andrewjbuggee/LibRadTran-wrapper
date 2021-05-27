%% --- Read Output Files from UVSPEC ---
% ======================================
% The purpose of this script is to read the data output from the output
% file created by uvspec. The code will determine the headers for each
% column of data, and the numerical values. Headers will be stored in the
% first row of a cell array. The data will be stored in the second row of
% the cell array.



% --- By Andrew J. Buggee ---
%% --- Read in Files ---

function [dataStruct,headers_units] = readUVSPEC(path,fileName)


% [fileName,path] = uigetfile('.txt');
delimeter = ' ';
headerLine = 0; % 0 if no header

data = importdata([path,fileName],delimeter,headerLine);


%% --- Converstion to a Structure ---

% if the RTE solver is disort, sdisort, or spsdisort

headers_units = cell(2,7);
headers_units{1,1} = 'wavelength';
headers_units{1,2} = 'dirIrrad';
headers_units{1,3} = 'difDwnIrrad';
headers_units{1,4} = 'difUpIrrad';
headers_units{1,5} = 'dirContMeanIrrad';
headers_units{1,6} = 'difDwnContMeanIrrad';
headers_units{1,7} = 'difUpContMeanIrrad';
headers_units{2,1} = 'nm';
headers_units{2,2} = 'mW/(m^{2} nm)';
headers_units{2,3} = 'mW/(m^{2} nm)';
headers_units{2,4} = 'mW/(m^{2} nm)';
headers_units{2,5} = 'mW/(m^{2} nm)';
headers_units{2,6} = 'mW/(m^{2} nm)';
headers_units{2,7} = 'mW/(m^{2} nm)';

% and now we'll create the structure

dataStruct = struct(headers_units{1,1},data(:,1),headers_units{1,2},data(:,2),...
    headers_units{1,3},data(:,3),headers_units{1,4},data(:,4),...
    headers_units{1,5},data(:,5),headers_units{1,6},data(:,6),...
    headers_units{1,7},data(:,7));



end

