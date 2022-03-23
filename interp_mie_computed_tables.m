%% Read and Interpolate Mie Calculations

% This function will read and interpolate precompute Mie calculations for
% water droplets of varrying radii.

% INPUTS:
%   (1) distribution - choose between two lookup tables:
%       (a) 'gamma' - one using a gamma distribution of droplets with an alpha
%       factor of 7
%       (b) 'mono' - one using a single particle of precisely the diameter in
%       question
%   (2) xq - querry points. If one wants to know the mie properties for a
%   droplet of radius r at wavelength w, xq is a vector that defines the
%   locations r and w for interpolation. xq = [w,r] so please provide the
%   wavelength first and then the radius. The wavelength should be in
%   nanometers and the radius should be in microns. Sorry!

% OUTPUTS:
%   (1) yq - the values of each mie parameter interpolated at the locations
%   specified by xq. The parameters calculated in the look up table are:
%       (a) refrac_real - real part of the refractive index
%       (b) refrac_imag - imaginary part of the refractive index
%       (c) q_ext - the extinction efficiency
%       (d) omega - the single scattering albedo
%       (e) gg - asymmetry parameter
%       (f) q_scat - scattering efficiency

% All look up tables were computed using the opensoure radiative transfer
% code, LibRadTran

% By Andrew John Buggee

% ------------------------------------------------------------------------
%%

function [yq] = interp_mie_computed_tables(xq,distribution)

% ----------------------------------------
% ------------- Check Inputs! ------------
% ----------------------------------------

% Check to make sure there are two inputs


if nargin~=2
    error([newline,'Not enough inputs. Need 2: 1 defines the query points, the other chooses the file type', newline])
end

% Check to make sure xq is a vector with two values

if size(xq,2)~=2
    error([newline,'The query vector xq must have two inputs, one for wavelength and one for radii', newline])
end


% ------------------------------------------
% ------------- Function Stuff! ------------
% ------------------------------------------

% Determine which computer you're using
computer_name = whatComputer;

% use the proper path
if strcmp(computer_name,'anbu8374')==true
    folder_path = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';
    
elseif strcmp(computer_name,'andrewbuggee')==true
    
    error('You havent stored the mie calculations on you laptop yet!')
    
end

% -- Define the boundaries of interpolation for wavelength and radius --

wavelength_bounds = [100, 3000];            % nanometers - wavelength boundaries
r_eff_bounds = [1, 100];                    % microns - effective radius boundaries

% ---- Create the grids for interpolation ----

wl = wavelength_bounds(1):wavelength_bounds(2);         % nm
r_eff = r_eff_bounds(1):r_eff_bounds(2);                % microns

[WL, R_eff] = meshgrid(wl,r_eff);                       % Meshgrid for inerpolation


% The data fields are in the following order:
%       (1) wavelength (nanometers)
%       (2) effective radius (microns)
%       (3) refrac_real - real part of the refractive index
%       (4) refrac_imag - imaginary part of the refractive index
%       (5) q_ext - the extinction efficiency
%       (6) omega - the single scattering albedo
%       (7) gg - asymmetry parameter
%       (8) q_scat - scattering efficiency

num_calcs = size(xq,1);                             % This is the number of interpolation points

if strcmp(distribution, 'gamma')==true
    
    % Let's load the mie compute look-up table for a gamma droplet
    % distribution
    
    delimeter = ' ';
    headerLine = 0; % 0 if no header
    
    
    
    gamma_filename = 'Q_ext_4_AVIRIS_1nm_sampling_gamma_7.OUT';
    
    data = importdata([folder_path,gamma_filename],delimeter,headerLine);
    data = reshape(data',8, 100, []);                                       % converts to data cube (row,col,depth) = (parameters,r_eff, lambda)
    
    
    % Set up the zero array
    yq = zeros(1,8);
    
    
    % ------------------------------------------------------------
    % Let's check to make sure the wavelength and effective radius
    % query locations are within the bounds of the table. If either
    % are outside the bounds of interpolation, we will extrapolate
    % and issue a warning
    % ------------------------------------------------------------
    
    if any(xq(:,1)<= wavelength_bounds(1)) || any(xq(:,1)>=wavelength_bounds(2)) || any(xq(:,2) <= r_eff_bounds(1)) || any(xq(:,2) >= r_eff_bounds(2))
        
        % if any of these are true, then we will extrapolate
        error(['Query points are outside the bounds of the data set. The acceptable ranges are:',newline,...
            'Wavelength: [100, 3000] nm', newline,...
            'Effective Radius: [1, 100] microns', newline]);
        
    else
        
        % then we will interpoalte
        % Lets grab all of the values we need in the data set
           for nn = 1:num_calcs
            
            for ii = 1:(size(data,1)-2)                         % The first two values are wavelength and effective radius
                
                data2interpolate = reshape(data(ii+2,:,:), 100,[]);
                yq(nn,ii) = interp2(WL, R_eff, data2interpolate, xq(nn,1), xq(nn,2));
                
            end
            
            
        end
        
        % Lets include the wavelength and effective radius in the
        % interpolated data cube
        yq = [xq, yq];
        
        
        
    end
    
    
    
    
elseif strcmp(distribution, 'mono')==true
    
    % Let's load the mie compute look-up table for a monodispersed droplet
    % distribution
    
    delimeter = ' ';
    headerLine = 0; % 0 if no header
    
    
    
    mono_filename = 'Q_ext_4_AVIRIS_1nm_sampling_monodispersed.OUT';
    
    data = importdata([folder_path,mono_filename],delimeter,headerLine);
    data = reshape(data',8, 100, []);                                       % converts to data cube (row,col,depth) = (parameters,r_eff, lambda)
    
    % Set up the zero array
    yq = zeros(1,size(data,1)-2);                                           % The first two rows are not needed
    
    if any(xq(:,1)<= wavelength_bounds(1)) || any(xq(:,1)>=wavelength_bounds(2)) || any(xq(:,2) <= r_eff_bounds(1)) || any(xq(:,2) >= r_eff_bounds(2))
        
        % if any of these are true, then we will extrapolate
        error(['Query points are outside the bounds of the data set. The acceptable ranges are:',newline,...
            'Wavelength: [100, 3000] nm', newline,...
            'Effective Radius: [1, 100] microns', newline]);
        
    else
        
        % then we will interpoalte
        % Lets grab all of the values we need in the data set
        for nn = 1:num_calcs
            
            for ii = 1:(size(data,1)-2)                         % The first two values are wavelength and effective radius
                
                data2interpolate = reshape(data(ii+2,:,:), 100,[]);
                yq(nn,ii) = interp2(WL, R_eff, data2interpolate, xq(nn,1), xq(nn,2));
                
            end
            
            
        end
        
        % Lets include the wavelength and effective radius in the
        % interpolated data cube
        yq = [xq, yq];
        
        
        
    end
    
else
    error([newline,'The distribution you provided is not valid. Enter "gamma" or "mono"',newline])
    
    
    
end




end
