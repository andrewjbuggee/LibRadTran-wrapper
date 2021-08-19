%% ---- QUICK EDITS TO .INP AND .DAT FILES -----


% - oldFolder is the name of the folder where the old file is stored
% - newFolder is the name of the new folder where the new file is saved
% - oldFile is the .INP or .DAT file that needs to be edited
% - newFile is the new saved file. Code will make a copy of oldFilename
% and save it as a new file after editing
% - oldExpr is the expression to change
% - newExpr is the expression that will replace expr2look

% By Andrew J. Buggee
%%

function [] = edit_INP_DAT_files(oldFolder,newFolder,oldFile,newFile,oldExpr,newExpr)

% open old file to edit
oldText = fileread([oldFolder,oldFile]);

% find location of expression to change
[~,endI] = regexp(oldText,oldExpr,'match'); % find the old expression location

% replace old expression with new expression
oldText(endI:(endI+length(oldExpr)-1)) = newExpr; % insert new expression

% save the edited text as a new file in the new folder
writematrix(oldText,[newFolder,newFile],'Delimiter',' ','FileType','text','QuoteStrings',0);




end