%% --- Read Output Files from UVSPEC ---
% ======================================



clear all; close all;
% --- By Andrew J. Buggee ---
%% --- Read in Files ---

[fileName,path] = uigetfile('.txt');
delimeter = ' ';
headerLine = 0; % 0 if no header

data = importdata([path,fileName],delimeter,headerLine);




