%% --- Read Output Files from UVSPEC ---
% ======================================
% The purpose of this script is to read the data output from the output
% file created by uvspec. The code will determine the headers for each
% column of data, and the numerical values. Headers will be stored in the
% first row of a cell array. The data will be stored in the second row of
% the cell array.


clear all; close all;
% --- By Andrew J. Buggee ---
%% --- Read in Files ---

[fileName,path] = uigetfile('.txt');
delimeter = ' ';
headerLine = 0; % 0 if no header

data = importdata([path,fileName],delimeter,headerLine);

x = [1,2,3]; % important line

% Now I will make lots of important changes in the new branch. Lets see if
% this comes up in my remote branch. 

y = fft(x); % wow! an fft!

