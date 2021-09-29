%% ----- Create new .INP files from MODIS hdf data -----

% Inputs: 
%   - EV: modis data. you must input an array, thus you need to pick a
%   specific band. A data cube will not work
%   - solar: the solar strucutre that contains the solar locaiton
%   - sensor: the sensor structure that contains locaiton of the sensor
%   - stepSize: The EV array is usually thousands of pixels wide on either
%   side. If you pick a stepSize of 1, ever single a radiative transfer
%   file .INP will be calculated for the geometry of every pixel. If you'd
%   like to write a .INP for every 500 pixels, set the step size to be 500.

% By Andrew J. Buggee

%%

function [] = write_INP_4_MODIS_hdf(inpNames)

% for each spectral bin, we have an image on the ground composed of 2030 *
% 1354 pixels. The swath on the ground is large enough that the solar
% zenith and solar azimuth change significantly. Ideally at each spectral bin, and
% each pixel, we could calculate the reflectance function and how it varies
% with changing tau and change re. 


% a template file has been set up to be edited and saved as a new file
oldFolder = ['/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/MODIS_08_25_2021/'];

% Define where the new file should be saved
newFolder = oldFolder;


% introduce change variables in the file name
re = 4:4:20; % effective radius
tau_c = [1,5:5:30]; % cloud optical depth




% lets determine the band, the solar zenith angle, the solar azimuth angle,
% the viewing zenith angle and the zenith azimuth angle
% numRows = size(solar.zenith,1);
% numCols = size(solar.zenith,2);
% 
% numBands = length(EV.bands.number);

% step through each file, edit it and save it as a new file

for kk = 1: length(inpNames)
    
    for ii = 1:length(re)
        for jj = 1:length(tau_c)
            
            % redefine the old file each time
            oldFile = inpNames{kk};
            newFile = [inpNames{kk}(1:end-4),'_r_',num2str(re(ii)),'_T_',num2str(tau_c(jj)),'.INP'];
            
            oldExpr = 'wc_file 1D ../data/wc/WC_r04_T01.DAT';
            
            if re(ii)<10 && tau_c(jj)<10
                newExpr = ['wc_file 1D ../data/wc/WC_r0',num2str(re(ii)),'_T0',num2str(tau_c(jj)),'.DAT'];
                
            elseif re(ii)>=10 && tau_c(jj)<10
                newExpr = ['wc_file 1D ../data/wc/WC_r',num2str(re(ii)),'_T0',num2str(tau_c(jj)),'.DAT'];
            elseif re(ii)>=10 && tau_c(jj)>=10
                newExpr = ['wc_file 1D ../data/wc/WC_r',num2str(re(ii)),'_T',num2str(tau_c(jj)),'.DAT'];
            elseif re(ii)<10 && tau_c(jj)>=10
                newExpr = ['wc_file 1D ../data/wc/WC_r0',num2str(re(ii)),'_T',num2str(tau_c(jj)),'.DAT'];
                
            end
            
            
            
            edit_INP_DAT_files(oldFolder,newFolder,oldFile,newFile,oldExpr,newExpr);
            
        end
    end
    
end




end





