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

function [] = write_INP_4_MODIS_hdf(EV,solar,sensor,stepSize)

% for each spectral bin, we have an image on the ground composed of 2030 *
% 1354 pixels. The swath on the ground is large enough that the solar
% zenith and solar azimuth change significantly. Ideally at each spectral bin, and
% each pixel, we could calculate the reflectance function and how it varies
% with changing tau and change re. 

tau_c = [1,5:30]; % range of cloud optical depth stored in the cloud file
re = 4:4:20; % range of effective droplet radius stored in the cloud files

% a template file has been set up to be edited and saved as a new file
oldFolder = ['/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/',...
    'LibRadTran/libRadtran-2.0.4/MODIS_08_25_2021/'];
oldFile = 'band_sza_saz_template.INP';

% Define where the new file should be saved
newFolder = oldFolder;


% lets determine the band, the solar zenith angle, the solar azimuth angle,
% the viewing zenith angle and the zenith azimuth angle
numRows = size(solar.zenith,1);
numCols = size(solar.zenith,2);

numBands = length(EV.bands.number);

for kk = 1:numBands
    
    
    for ii = 1:stepSize:numRows
        
        for jj = 1:stepSize:numCols
            
            % create new file name
            bandName = num2str(EV.bands.center);
            szaName = num2str(solar(ii,jj).zenith);
            sazName = num2str(solar(ii,jj),azimuth);
            
            
            newFile = ['band_',bandName,'_sza_',szaName,'_saz_',sazName,'.INP'];
            
            newExpr{1} = num2str(solar.zenith(ii,jj)./100); % solar zenith angle
            newExpr{2} = num2str(solar.azimuth(ii,jj)./100); % solar azimuth angle
            
            newExpr{3} = num2str(sensor.zenith(ii,jj)./100); % sensor zenith angle, as seen from the pixel on the ground
            newExpr{4} = num2str(sensor.azimuth(ii,jj)./100); % sensor azimuth angle, as seen from the pixel on the ground
            
            newExpr{5} = num2str([EV.bands.lowerBound EV.bands.upperBound]);  % lower and upper bound of the spectral bin
            
            oldExpr{1} = 'sza 0.0'; % solar zenith angle
            oldExpr{2} = 'phi0 0.0'; % solar azimuthal angle
            oldExpr{3} = 'umu 0.0'; % cosine of the zenith view angle
            oldExpr{4} = 'phi 0.0'; % viewing azimuth angle
            oldExpr{5} = 'wavelength 0.0 0.0'; % wavelength range in nm, we want to change the lower and upper bound using new expr
            
            
            
                
             edit_INP_DAT_files(oldFolder,newFolder,oldFile,newFile,oldExpr,newExpr);

            
            
            
            
        end
        
        
    end
    
end





end





