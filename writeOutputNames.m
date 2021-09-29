%% ----- Write output file names for uvspec -----




% By Andrew J. Buggee

%%


function [outputNames] = writeOutputNames(inputNames)

numRows = size(inputNames,1);
numCols = size(inputNames,2);
numZ = size(inputNames,3);

outputNames = cell(size(inputNames));

for ii = 1:numZ
    
    for jj = 1:numRows
        
        for kk = 1:numCols
            
            outputNames{jj,kk,ii} = ['OUTPUT_',inputNames{jj,kk,ii}(1:end-4)];
         
            
        end
        
    end
    
end



end