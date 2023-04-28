%% Wrapper for Creating Water Cloud files


% By Andrew John Buggee
%%

% -------------------------------------------------------
% ----------------- FOR MACBOOK -------------------------
% -------------------------------------------------------

% Define the folder for where this INP file should be saved
% folderName = ['/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval/',...
%              'LibRadTran/libRadtran-2.0.4/testing_UVSPEC/'];


% -------------------------------------------------------
% --------------------- FOR MAC -------------------------
% -------------------------------------------------------

% Define the folder for where this INP file should be saved
folderName = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/testing_UVSPEC/';


% Define override of total precipitable water. This will force the total
% column of water vapor to be whatever value you define.
% If you don't wish to change the default, define the variable with nan
total_h2O_column = 4.03;        % mm of precipitable water


% define the wavelength range. If monochromatic, enter the same number
% twice
wavelength = [620 670];              % nm - monochromatic wavelength calcualtion

% define the solar zenith angle
sza = 35;                       % degree

% define teh solar azimuth angle
phi0 = 109;

% define the viewing azimuth angle
vaz = 95;

% define the viewing zenith angle
vza = acosd(0.515);                        % degree

% define the surface albedo
albedo = 0.05;



% -----------------------------------
% ---- Write a Water Cloud file! ----
% -----------------------------------

% if you wish to have a cloud, define the flag variable below as true
yesCloud = true;


% define the total cloud optical depth
tau_c = 16.68;
% define the droplet size
re = 11.88;                        % microns
% define the geometric location of the cloud top and cloud bottom
z_topBottom = [9,8];          % km above surface
% define the type of droplet distribution
distribution_str = 'gamma';
% define the distribution varaince
distribution_var = 7;
% define whether this is a vertically homogenous cloud or not
vert_homogeneous_str = 'vert-homogeneous';
% define how liquid water content will be computed
parameterization_str = 'mie';

% define the wavelength used for the optical depth
lambda_forTau = 650;            % nm



wc_filename = write_wc_file(re,tau_c,z_topBottom, lambda_forTau, distribution_str,...
    distribution_var, vert_homogeneous_str, parameterization_str);

% Define the percentage of cloud cover
percent_cloud_cover = 1;

% Define the parameterization scheme used to comptue the optical quantities
wc_parameterization = 'mie interpolate';
% --------------------------------------------------------------
% --------------------------------------------------------------



% define the atmospheric data file
atm_file = 'afglus.dat';


% define the name of the input file
if yesCloud==true
        inputName = [num2str((wavelength(2)-wavelength(1))/2 + wavelength(1)),...
                    'nm_withCloudLayer_',num2str(sza),'sza_',num2str(round(vza)),...
                'vza_',atm_file(1:end-4),'.INP'];
else
        inputName = [num2str((wavelength(2)-wavelength(1))/2 + wavelength(1)),...
            'nm_',num2str(sza),'sza_',num2str(round(vza)),...
                'vza_',atm_file(1:end-4),'.INP'];
end



% Define the .OUT file name
outputName = ['OUTPUT_',inputName(1:end-4)];






% ---- ****************** ------
% ---- Write the INP File ------
% ---- ****************** ------

% Open the old file for writing
fileID = fopen([folderName,inputName], 'w');

% Define which RTE solver to use
% ------------------------------------------------
formatSpec = '%s %s %5s %s \n';
fprintf(fileID, formatSpec,'rte_solver','disort',' ', '# Radiative transfer equation solver');


% Define the number of streams to keep track of when solving the equation
% of radiative transfer
% ------------------------------------------------
formatSpec = '%s %s %5s %s \n\n';
fprintf(fileID, formatSpec,'number_of_streams','6',' ', '# Number of streams');


% Define the location and filename of the atmopsheric profile to use
% ------------------------------------------------
formatSpec = '%s %5s %s \n';
fprintf(fileID, formatSpec,['atmosphere_file ','../data/atmmod/',atm_file],' ', '# Location of atmospheric profile');

% Define the location and filename of the extraterrestrial solar source
% ---------------------------------------------------------------------
formatSpec = '%s %s %5s %s \n\n';
fprintf(fileID, formatSpec,'source solar','../data/solar_flux/kurudz_1.0nm.dat', ' ', '# Bounds between 250 and 10000 nm');


% Define the total precipitable water
% ------------------------------------------------
if isnan(total_h2O_column)==false
    formatSpec = '%s %s %f %s %5s %s \n';
    fprintf(fileID, formatSpec,'mol_modify','H2O', total_h2O_column,' MM', ' ', '# Total Precipitable Water');
end


% Define the surface albedo
% ------------------------------------------------
formatSpec = '%s %s %5s %s \n\n';
fprintf(fileID, formatSpec,'albedo', albedo, ' ', '# Surface albedo of the ocean');


if yesCloud==true

    % Define the water cloud file
    % ------------------------------------------------
    formatSpec = '%s %s %5s %s \n';
    fprintf(fileID, formatSpec,'wc_file 1D', ['../data/wc/',wc_filename{1}], ' ', '# Location of water cloud file');
    
    
    % Define the percentage of horizontal cloud cover
    % This is a number between 0 and 1
    % ------------------------------------------------
    formatSpec = '%s %f %5s %s \n';
    fprintf(fileID, formatSpec,'cloudcover wc', percent_cloud_cover, ' ', '# Cloud cover percentage');
    
    
    % Define the technique or parameterization used to convert liquid cloud
    % properties of r_eff and LWC to optical depth
    % ----------------------------------------------------------------------
    formatSpec = '%s %s %5s %s \n\n';
    fprintf(fileID, formatSpec,'wc_properties', wc_parameterization, ' ', '# optical properties parameterization technique');

end

% Define the wavelengths for which the equation of radiative transfer will
% be solve
% -------------------------------------------------------------------------
formatSpec = '%s %f %f %5s %s \n\n';
fprintf(fileID, formatSpec,'wavelength', wavelength(1), wavelength(2), ' ', '# Wavelength range');


% Define the sensor altitude
% ------------------------------------------------
formatSpec = '%s %s %5s %s \n';
fprintf(fileID, formatSpec,'zout', 'toa', ' ', '# Sensor Altitude');

% Define the solar zenith angle
% ------------------------------------------------
formatSpec = '%s %f %5s %s \n';
fprintf(fileID, formatSpec,'sza', sza, ' ', '# Solar zenith angle');

% Define the solar azimuth angle
% ------------------------------------------------
formatSpec = '%s %f %5s %s \n';
fprintf(fileID, formatSpec,'phi0', phi0, ' ', '# Solar azimuth angle');

% Define the cosine of the zenith viewing angle
% ------------------------------------------------
formatSpec = '%s %f %5s %s \n';
fprintf(fileID, formatSpec,'umu', cosd(vza), ' ', '# Cosine of the zenith viewing angle');

% Define the azimuth viewing angle
% ------------------------------------------------
formatSpec = '%s %f %5s %s \n\n';
fprintf(fileID, formatSpec,'phi', vaz, ' ', '# Azimuthal viewing angle');


% Set the error message to quiet of verbose
% ------------------------------------------------
formatSpec = '%s';
fprintf(fileID, formatSpec,'verbose');


% Close the file!
fclose(fileID);
% ----------------------------------------------------
% ----------------------------------------------------

