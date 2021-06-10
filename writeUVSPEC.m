%% ----- WRITE UVSPEC INPUT FILES -----

% include a flag for verbose versus quiet, which will either create an
% error message text file or not




% By Andrew J. Buggee
%% Below are the instructions of how the file should be written

%   1) The very first line should be the rte_solver type. All values and
%   comments should be separated by only 1 space. This allows matlab to
%   simply read input settings.

%   2) 



function [outputArg1,outputArg2] = writeUVSPEC(inputArg1,inputArg2)
%WRITEUVSPEC Summary of this function goes here
%   Detailed explanation goes here
outputArg1 = inputArg1;
outputArg2 = inputArg2;






%% ---- SETTING UP RTE SOLVER ----

% need to set the type of RTE solver:   
%       1) twostr (Two-Stream Approximation) - this is a 1D,
%       pseudo-spherical solver that calculates irradiance and actinic
%       flux. It is a very fast approximation, but it cannot solve for
%       radiances. 

%       2) disort - a 1D plane-parralel solver that calculates irradiance,
%       actinic flux and radiance. This is the default solver of UVSPEC,
%       and when in doubt, use disort. 


%% ---- SETTING UP SOLAR SOURCE SPECTRUM ----

% There are many options for a solar source. The defualt is simply 'solar'
% and, is using the default REPTRAN band parameterization, you can select
% wavelengths from 120 to 5000 nm. The options are:

%       1) source solar -- The default source which allows for spectrum
%       values between 120 and 5000 nm. 

%       2) source solar ../data/solar_flux/atlas_plus_modtran -- This high
%       resolution source only allows for a wavelengths between 200 and
%       799.95nm. This file does differ slightly from option 1, though it is
%       unclear why they differ at the time of this writing


%% --- Geometry Configuration ----

%   1) sza - Solar Zenith Angle - There can only be one per file. Units:
%   degrees

%   4) phi0 - Solar Azimuth Angle - There can only be one per file. Units:
%   degrees

%   2) umu - Cosine(Zenith Viewing Angle) - Cosine of the viewing angle
%   where a viewing angle of 0 is straight down into the Earth, rather than
%   straight up. But according to the manual, umu>0 is looking downward
%   (e.g. a satellite). So what this might mean is when umu<0 the default
%   sensor height is at TOA. umu<0 is looking upward. To make a
%   vector, just include spaces in between each value. note: a umu of 0 is
%   not allowed! This will lead to infinities because 1/umu when umu of 0
%   is infinity. And this is how we calculate the slant path. The values have to
%   be increasing in order to be read. Units: degrees

%   3) phi - sensor aziumuth - this is the azimuth of the sensor. This can
%   be input as a vector by leaving a blank space inbetween values. If a
%   vector is used, values must be increasing. Units: degrees

%   5) zout - sensor altitude - the atmospheric profiles will adjust
%   according to where the sensor is. For a satellite, set: zout TOA. This
%   will place the sensor at the top of the atmosphere. Then all umu values
%   should be greater than zero to specify looking downward. If zout is 0,
%   then umu should always be less than zero to specify that you are
%   looking upward.


%% ---- Wavelength range and Slit Functions ----

%   1) slit_function_file - location of the slit function data file. This
%   for some reason has limitations. For example I cannot run a file with a
%   slit function over the range 400 - 800 nanometers, for whatever reason.
%   When I was using modtran we often used a slit function so the
%   transition between spectral bins was smooth. Atmospheric data taken
%   from measurements are located at discrete wavelengths. Slit functions
%   are used to interpolate across values and create more continuous
%   outputs. I should look into the different built in slit functions and
%   the limitations of each

%   2) wavelength - when only specifying a wavelength range using disort,
%   there are finite boundaries.


%% ---- Additional Output Quantities ----


% there is a host of additional outputs the user can opt for

%       1) output_quantity transmittance -- This outputs the spectral
%       transmittance of reflectance in place of all absolute quantities. 
%       Important note: the transmittance does not account for the 
%       sun-earth distance. It simply calculates I/I0. But
%       the transmittance DOES change for different SZA. I'm not sure why I
%       would want to use the transmissivity

%       2) output_quantity transmissivity -- The output calculates the
%       spectral transmittance instead of absolute quantities. But its
%       formula is different from option 1: I/(I0 * cos(x)) where
%       x is the solar zenith angle


end

