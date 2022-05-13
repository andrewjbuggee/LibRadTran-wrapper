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

%   (3) justQext_flag - tells the code you only need Qext - The entire
%   Mie_Properties file is 29 MB, which takes a while to load! To write 10
%   wc files, reading in the Mie_Properties file 10 times, it takes 8
%   seconds. But most of the time we only need Qext, so there is a file for
%   both the monodispersed and the gamma distribution that contains only
%   the computed values for Qext, which is just 2.9 MB.

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

function [yq] = interp_mie_computed_tables(xq,distribution, justQext_flag)

% ----------------------------------------
% ------------- Check Inputs! ------------
% ----------------------------------------

% Check to make sure there are two inputs


if nargin~=3
    error([newline,'Not enough inputs. Need 3: the first defines the query points, ',...
        'the next chooses the droplet size distribution, and the last tells the code to load ',...
        'the entire Mie_Properties table, or just the Q_ext values.', newline])
end

% Check to make sure xq is a vector with two values

if size(xq,2)~=2
    error([newline,'The query vector xq must have two inputs, one for wavelength and one for radii', newline])
end

% Determine which computer you're using
computer_name = whatComputer;

% use the proper path
if strcmp(computer_name,'anbu8374')==true
    folder_path = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';
    
elseif strcmp(computer_name,'andrewbuggee')==true
    folder_path = '/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';
    
end

%%
% ------------------------------------------
% ------------- Function Stuff! ------------
% ------------------------------------------


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
    
    if justQext_flag==true
        
        % if this is true, we only load the Q_ext calculations!
        filename = 'Q_ext_4_AVIRIS_1nm_sampling_gamma_7.txt';
        format_spec = '%f';        % 1 column of data
        
        
        
        % ----- READ IN DATA USING TEXTSCAN() ---------------
        
        file_id = fopen([folder_path,filename]);
        
        data = textscan(file_id, format_spec);
        data = reshape(data{1},100,[]);                                     % rehsape the data into a matrix
        % Set up the zero array
        yq = zeros(1,num_calcs);                                           % The first two rows are not needed
        
        
        if any(xq(:,1)<= wavelength_bounds(1)) || any(xq(:,1)>=wavelength_bounds(2)) || any(xq(:,2) <= r_eff_bounds(1)) || any(xq(:,2) >= r_eff_bounds(2))
            
            % if any of these are true, then we will extrapolate
            error(['Query points are outside the bounds of the data set. The acceptable ranges are:',newline,...
                'Wavelength: [100, 3000] nm', newline,...
                'Effective Radius: [1, 100] microns', newline]);
            
        else
            
            % then we will interpoalte
            % Lets grab all of the values we need in the data set
            for nn = 1:num_calcs
                
                yq(nn) = interp2(WL, R_eff, data, xq(nn,1), xq(nn,2));
                
            end
            
            % Lets include the wavelength and effective radius in the
            % interpolated data cube
            yq = [xq, yq'];
            
            
            
        end
        
    else
        
        filename = 'Mie_Properties_4_AVIRIS_1nm_sampling_gamma_7.OUT';
        format_spec = '%f %f %f %f %f %f %f %f';        % 8 columns of data
        
        file_id = fopen([folder_path,filename]);
        
        data_table = textscan(file_id, format_spec);
        
        % Set up the zero array
        yq = zeros(1,length(data_table)-2);                                           % The first two rows are not needed
        
        
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
                
                for ii = 1:size(yq,2)                         % The first two values are wavelength and effective radius
                    
                    data = reshape(data_table{ii+2}, 100,[]);
                    yq(nn,ii) = interp2(WL, R_eff, data, xq(nn,1), xq(nn,2));
                    
                end
                
                
            end
            
            % Lets include the wavelength and effective radius in the
            % interpolated data cube
            yq = [xq, yq];
            
            
            
        end
        
        
    end
    
    
elseif strcmp(distribution, 'mono')==true
    
    % Let's load the mie compute look-up table for a monodispersed droplet
    % distribution
    
    
    
    if justQext_flag==true
        
        % if this is true, we only load the Q_ext calculations!
        filename = 'Q_ext_4_AVIRIS_1nm_sampling_monodispersed.txt';
        format_spec = '%f';        % 1 column of data
        
        
        
        % ----- READ IN DATA USING TEXTSCAN() ---------------
        
        file_id = fopen([folder_path,filename]);
        
        data_table = textscan(file_id, format_spec);
        data_table = reshape(data_table{1},100,[]);                                     % rehsape the data into a matrix
        % Set up the zero array
        yq = zeros(1,num_calcs);                                           % The first two rows are not needed
        
        
        if any(xq(:,1)<= wavelength_bounds(1)) || any(xq(:,1)>=wavelength_bounds(2)) || any(xq(:,2) <= r_eff_bounds(1)) || any(xq(:,2) >= r_eff_bounds(2))
            
            % if any of these are true, then we will extrapolate
            error(['Query points are outside the bounds of the data set. The acceptable ranges are:',newline,...
                'Wavelength: [100, 3000] nm', newline,...
                'Effective Radius: [1, 100] microns', newline]);
            
        else
            
            % then we will interpoalte
            % Lets grab all of the values we need in the data set
            for nn = 1:num_calcs
                
                yq(nn) = interp2(WL, R_eff, data_table, xq(nn,1), xq(nn,2));
                
            end
            
            % Lets include the wavelength and effective radius in the
            % interpolated data cube
            yq = [xq, yq'];
            
            
            
        end
        
    else
        
        filename = 'Mie_Properties_4_AVIRIS_1nm_sampling_monodispersed.OUT';
        format_spec = '%f %f %f %f %f %f %f %f';        % 8 columns of data
        
        file_id = fopen([folder_path,filename]);
        
        data_table = textscan(file_id, format_spec);
        
        % Set up the zero array
        yq = zeros(1,length(data_table)-2);                                           % The first two rows are not needed
        
        
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
                
                for ii = 1:size(yq,2)                         % The first two values are wavelength and effective radius
                    
                    data = reshape(data_table{ii+2}, 100,[]);
                    yq(nn,ii) = interp2(WL, R_eff, data, xq(nn,1), xq(nn,2));
                    
                end
                
                
            end
            
            % Lets include the wavelength and effective radius in the
            % interpolated data cube
            yq = [xq, yq];
            
            
            
        end
        
        
    end
    
else
    error([newline,'The distribution you provided is not valid. Enter "gamma" or "mono"',newline])
    
    
    
end



end



% ----- READ IN DATA USING IMPORTDATA() ---------------


%     delimeter = ' ';
%     headerLine = 0; % 0 if no header
%     data = importdata([folder_path,filename],delimeter,headerLine);
%     data = reshape(data',8, 100, []);                                       % converts to data cube (row,col,depth) = (parameters,r_eff, lambda)
%
%
%
%
%     % Set up the zero array
%     yq = zeros(1,size(data,1)-2);                                           % The first two rows are not needed
%
%     if any(xq(:,1)<= wavelength_bounds(1)) || any(xq(:,1)>=wavelength_bounds(2)) || any(xq(:,2) <= r_eff_bounds(1)) || any(xq(:,2) >= r_eff_bounds(2))
%
%         % if any of these are true, then we will extrapolate
%         error(['Query points are outside the bounds of the data set. The acceptable ranges are:',newline,...
%             'Wavelength: [100, 3000] nm', newline,...
%             'Effective Radius: [1, 100] microns', newline]);
%
%     else
%
%         % then we will interpoalte
%         % Lets grab all of the values we need in the data set
%         for nn = 1:num_calcs
%
%             for ii = 1:(size(data,1)-2)                         % The first two values are wavelength and effective radius
%
%                 data2interpolate = reshape(data(ii+2,:,:), 100,[]);
%                 yq(nn,ii) = interp2(WL, R_eff, data2interpolate, xq(nn,1), xq(nn,2));
%
%             end
%
%
%         end
%
%         % Lets include the wavelength and effective radius in the
%         % interpolated data cube
%         yq = [xq, yq];
%
%
%
%     end


