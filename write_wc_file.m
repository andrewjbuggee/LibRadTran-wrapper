%% This function will write a .DAT water cloud file for LibRadTran

% This function will read and interpolate precompute Mie calculations for
% water droplets of varrying radii.

% INPUTS:
%   (1) re - effective droplet radius (microns) - this must be a vector
%   that is equal in length to the number of layers you want in your cloud,
%   and also to re and z
%   If the cloud you wish to model has the same size droplets everywhere,
%   only a single layer is needed.

%   (2) tau_c - cloud optical depth (unitless) - this is the cloud optical
%   depth, which is a monochromatic calculation. There is a single value
%   that defines the optical depth of the cloud. LibRadTran defines cloud
%   files in terms of two values that do not depend on wavelength: re and
%   liquid water content (LWC). But usually people talk about clouds as
%   having a certain droplet size and a certain optical thickness.

%   (3) z - altitude above sea level (kilometers) - this is a vector with
%   the same length as re. The first value defines the base of
%   the cloud. If there are multiple values, each entry defines the start
%   of the next layer where the re value changes.

%   (4) H - geometric thickness of the cloud (kilometers) - this is a
%   single value that defines the total geometric cloud thickness.

%   (5) lambda - wavelength that defines the cloud optical depth
%   (nanometers) - This is the wavelength that defines the cloud optical
%   depth. There should only be one value!

% OUTPUTS:
%   (1) .Dat file saved in the libRadTran folder:
%   /.../libRadtran-2.0.4/data/wc

% All look up tables were computed using the opensoure radiative transfer
% code, LibRadTran

% By Andrew John Buggee

%%

function [] = write_wc_file(re,tau_c,z, H, lambda)

% ------------------------------------------------------------
% ---------------------- CHECK INPUTS ------------------------
% ------------------------------------------------------------

% Check to make sure there are 3 inputs, droplet radius, cloud optical
% depth, and the altitude vector associated with this cloud


if nargin~=5
    error([newline,'Not enough inputs. Need 5: droplet effective radius, optical depth, altitude',...
        ' geometric thickness and wavelength.', newline])
end

% Check to make sure re is the same length as the altitude vector

if length(re)==length(z)
    
else
    error([newline,'The query vector xq must have two inputs, one for wavelength and one for radii', newline])
end

if length(lambda)>1 || length(H)>1 || length(tau_c)>1
    
    error([newline,'There are 3 scalar quantities: \tau_c, \lambda, and H. Check the function notes!', newline])
end

% Lets check to make sure the inputs re, tau_c and z are within the
% reasonble bounds

% -- Define the boundaries of interpolation for wavelength and radius --

wavelength_bounds = [100, 3000];            % nanometers - wavelength boundaries
r_eff_bounds = [1, 100];                    % microns - effective radius boundaries

if lambda<wavelength_bounds(1) || lambda>wavelength_bounds(2)
    
    error([newline, 'Wavelength is out of the range for Mie calculations. Must be between [0, 3000] nm.', newline])
    
end

if any(re<r_eff_bounds(1)) || any(re>r_eff_bounds(2))
    
    error([newline, 're is out of the range for Mie calculations. Must be between [1, 100] microns.', newline])
    
end


% Lets set up a few warnings incase the values of effective radius are
% outside the bounds of the Hu and Stamnes or Mie Interpolate
% parameterization

if any(re<2.5) || any(re>60)
    warning([newline, 'At least one value in r_{e} is outside the range of the Hu and Stamnes parameterization',newline,...
        'This is the default parameterization used to convert water cloud parameters to optical properites.',newline,...
        'The range of acceptable values for this parameterization is [2.5, 60] microns.',newline]);
end

if any(re>25)
    warning([newline,'At least one value in r_{e} is greater than 25 microns, which is the upper limit',...
        ' to the Mie Interpolate parameterization that computes optical properties from the water cloud ',...
        'parameters. The acceptable range for Mie Interpolation is [1, 25] micorns.',newline]);
end

    


% Determine which computer you're using
computer_name = whatComputer;

% Find the folder where the mie calculations are stored
% find the folder where the water cloud files are stored.
if strcmp(computer_name,'anbu8374')==true
    
    mie_calc_folder_path = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';
    water_cloud_folder_path = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/data/wc/';
    
elseif strcmp(computer_name,'andrewbuggee')==true
    
    mie_calc_folder_path = '/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';
    water_cloud_folder_path = '/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/data/wc/';
    
end

%%

% ------------------------------------------------------------
% ---------------------- COMPUTE LWC -------------------------
% ------------------------------------------------------------

% ----- I have to fudge the density of water ------
% This is the only way I can get my estimates of optical depth to match
% LibRadTrans estimates

rho_liquid_water = 859900;              % grams/m^3 - density of liquid water
%rho_liquid_water = 1e6;                 % grams/cm^3 - density of liquid water at 0 C


re = reshape(re,length(re),1);                                    % re must be a column vector
z = reshape(z, length(z),1);                                      % z must be a column vector

% ------ open the precomputed mie table and interpolate! -------------
justQ = true;                       % Load the precomputed mie table of only Q_ext values
yq = interp_mie_computed_tables([repmat(lambda,size(re)), re], 'mono', justQ);
Qext = yq(:,5);                                                                          % Extinction efficiency

% ----- For now lets just assume were at the extinction paradox limit --
%Qext = repmat(2,size(re));
% -----------------------------------------------------------------

if length(z)>1
    Nc = tau_c./(pi*trapz((z-z(1))*1e3,Qext.*(re*1e-6).^2));                                     % m^(-3) - number concentration
else
    Nc = tau_c./(pi*(H*1e3)*Qext.*(re*1e-6).^2);                                     % m^(-3) - number concentration
    
end

lwc = 4/3 * pi * rho_liquid_water * (re*1e-6).^3 .* Nc;


% Create the water cloud file name
if length(re)>1
    fileName = ['WC_rtop',num2str(round(re(end))),'_rbot',num2str(round(re(1))),'_T',num2str(tau_c),'.DAT'];
else
    fileName = ['WC_r',num2str(round(re)),'_T',num2str(round(tau_c)),'.DAT'];
end


%%

% ------------------------------------------------------------
% ----------------- WE NEED TO APPEND ZEROS ------------------
% ------------------------------------------------------------

% Wherever the cloud is, there needs to be zeros above and below so the
% LibRadTran knows where the cloud boundary is

% both the effective radius and the LWC need zeros on either boundary,
% unless if the cloud is at the surface

if length(z)==1
    
    if min(z)==0
        % then we only append zeros above the cloud
        z = [z; z+H];
        re = [re; 0];
        lwc = [lwc; 0];
        
    else
        % Then we need zeros on either end
        z = [0; z; z+H];
        re = [0; re; 0];
        lwc = [0; lwc; 0];
        
    end
    
elseif length(z)>1
    
    
    % if the minimum z value is 0 then the cloud is at the surface
    if min(z)==0
        % then we only append zeros above the cloud
        z = [z; z(end) + (z(end)-z(end-1))];
        re = [re; 0];
        lwc = [lwc; 0];
        
    else
        % Then we need zeros on either end
        z = [0; z; z(end) + (z(end)-z(end-1))];
        re = [0; re; 0];
        lwc = [0; lwc; 0];
        
    end
    
end



%%

% ------------------------------------------------------------
% ---------------------- WRITE WC FILE -----------------------
% ------------------------------------------------------------



% Create the water cloud file
fileID = fopen([water_cloud_folder_path,fileName], 'w');

% fprintf writes lines in our text file from top to botom
% wc.DAT files are written with the higher altitudes at the top, and the
% surface at the bottom

% to write column vectors in a text file, we have to store them as row
% vectors

toWrite = [flipud(z)'; flipud(lwc)'; flipud(re)'];

% Create the opening comment lines of the WC.DAT file

fprintf(fileID, '%s %10s %7s %8s \n','#','z','LWC','R_eff');
fprintf(fileID, '%s %10s %7s %8s \n','#','(km)','(g/m^3)','(micron)');

% Write in the data
fprintf(fileID,'%12.3f %7.4f %8.3f \n', toWrite);
fclose(fileID);

end
