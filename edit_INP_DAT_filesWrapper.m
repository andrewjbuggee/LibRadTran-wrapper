%% ----- Script Wrapper for editing .INP and .DAT files ----



% By Andrew J. Buggee
%% --- EDIT .INP Files ---

oldFolder = ['/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/',...
            'LibRadTran/libRadtran-2.0.4/Reflectance_Function_MODIS_3_72mu/'];
        
newFolder = ['/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/',...
            'LibRadTran/libRadtran-2.0.4/Reflectance_Function_MODIS_3_72mu_rev2/'];



oldExpr = 'umu 0.5';

newExpr = 'umu 0.0';


% introduce change variables in the file name
re = 4:4:20; % effective radius
tau_c = [1,5:5:30]; % cloud optical depth


%% ---- Edit and Save new Files ----

% step through each file, edit it and save it as a new file

for ii = 1:length(re)
    for jj = 1:length(tau_c)
        
        % redefine the old file each time
        oldFile = ['3_72_micronBand_droplets_',num2str(re(ii)),'_microns_tau_',num2str(tau_c(jj)),'.INP'];
        newFile = oldFile;
        
        edit_INP_DAT_files(oldFolder,newFolder,oldFile,newFile,oldExpr,newExpr);
        
    end
end


