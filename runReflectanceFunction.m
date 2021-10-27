%% ----- Run the Reflectance Function calculation over a range of re and tau -----


% the input names file must chagne tau across the column space, and must
% change r across row space

% By Andrew J. Buggee

%%

function [R,Rl] = runReflectanceFunction(inputs,folderName,inputFileNames,outputFileNames)

% extract inputs

re = inputs.re;
tau_c = inputs.tau_c;


R = cell(size(inputFileNames)); % each value here is integrated over the band provided
Rl = cell(size(inputFileNames)); % each value here is the spectral reflectance over the entire band


% first step through the band dimension
for ii = 1:size(inputFileNames,3)
    
    
    % next step through the different values for r per band
    for kk = 1:size(inputFileNames,1)
        
        if kk == 1
            
            % start by running uvspec
            [inputSettings] = runUVSPEC(folderName,inputFileNames(kk,:,ii),outputFileNames(kk,:,ii));
            
            % save the input settings file. In this case each band will have the
            % same geometry so we only need to save a single settings file per band
            save([folderName,'settings.mat'],"inputSettings"); % save inputSettings to the same folder as the input and output file
            
        else
            runUVSPEC(folderName,inputFileNames(kk,:,ii),outputFileNames(kk,:,ii));
        end
        
        % read in the data structure and calculate reflectance function
        
        ds = cell(1,length(outputFileNames(kk,:,ii)));
        
        % Finally, step through the different values of optical thickness
        for jj = 1:length(outputFileNames(kk,:,ii))
            
            [ds{jj},~,~] = readUVSPEC(folderName,outputFileNames{kk,jj,ii},inputSettings(jj+1,:)); % headers don't change per iteration
            [R{kk,jj,ii},Rl{kk,jj,ii}] = reflectanceFunction(inputSettings(jj+1,:),ds{jj});
            
        end
        
        
    end
    
    % save just the geometry and band number
    save([inputFileNames{1,1,ii}(1:39),'_ReflectanceFunc.mat'],"R","Rl","tau_c","re"); % save inputSettings to the same folder as the input and output file

    
end

% save reflectance function calculations

