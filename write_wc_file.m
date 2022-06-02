%% This function will write a .DAT water cloud file for LibRadTran

% This function will read and interpolate precompute Mie calculations for
% water droplets of varrying radii.

% INPUTS:
%   (1) re - effective droplet radius (microns) - this is either a single
%   value, a vector, or a matrix. A single value for re tells the function
%   to create a cloud with a single layer containing a constant droplet
%   radius value. A vector tells the function to create a single wc file
%   with a droplet profile. The length of the vector is equal to the number
%   of layers modeled. A matrix tells the function to create multiple wc
%   files, where the number of columns is equal to the number of wc files
%   created. The number of rows is equal to the number of layers modeled.
%   To create many water cloud files at once that model a homogenous cloud,
%   simply set the column vectors of re to be identical values.

%   (2) tau_c - cloud optical depth (unitless) - this is the cloud optical
%   depth, which is a monochromatic calculation. There is a single value
%   that defines the optical depth of the cloud. LibRadTran defines cloud
%   files in terms of two values that do not depend on wavelength: re and
%   liquid water content (LWC). But usually people talk about clouds as
%   having a certain droplet size and a certain optical thickness. Enter a
%   single value for a single wc file, or a vector if you're creating
%   multiple wc files. If re is a matrix, and tau_c is a single value, each
%   wc file will have the entered tau_c

%   (3) z_topBottom - altitude above sea level (kilometers) - this is a
%   vector with two values: [z_cloudTop, z_cloudBottom]. LibRadTran
%   constructs a cloud by creating layers, where each layer is homogenous
%   untill the next layer is defined. z_cloudTop defines where the cloud
%   ends; this is where the LWC should go to zero. This function will
%   compute a z vector equal in length to that of re using z_topBottom and
%   the geometric thickness H. If re is a matrix, the function expects
%   z_topBottom to be a matrix, where each column is a new wc file. If re
%   is a matrix, and z_topBottom is a vector, then this will be used for
%   every wc file.

%   (4) H - geometric thickness of the cloud (kilometers) - this is a
%   single value that defines the total geometric cloud thickness. For
%   multiple wc files, this must be a vector. If re is a matrix and H is a
%   single value, this value will be used for every wc file

%   (5) lambda - wavelength that defines the cloud optical depth
%   (nanometers) - This is the wavelength that defines the cloud optical
%   depth. If creating a single wc file, lambda is a single value. If
%   creating multiple wc files, lambda is a vector equal in length to the
%   number of columns of re. If re is a matrix and lambda is a single
%   value, this value will be used for each wc file created.

%   (6) distribution_str - a string telling the code with droplet size
%   distribution to use  - One can chose from two options:
%       (a) 'mono' - monodispersed distribution
%       (b) 'gamma' - gamma droplet distribution. By default this will use
%       a gamma distribution with an alpha value of 7, which is typical for
%       liquid water clouds.

% OUTPUTS:
%   (1) .Dat file saved in the libRadTran folder:
%   /.../libRadtran-2.0.4/data/wc

% All look up tables were computed using the opensoure radiative transfer
% code, LibRadTran

% By Andrew John Buggee

%%

function [fileName] = write_wc_file(re,tau_c,z_topBottom, H, lambda, distribution_str)

% ------------------------------------------------------------
% ---------------------- CHECK INPUTS ------------------------
% ------------------------------------------------------------

% Check to make sure there are 3 inputs, droplet radius, cloud optical
% depth, and the altitude vector associated with this cloud


if nargin~=6
    error([newline,'Not enough inputs. Need 5: droplet effective radius, optical depth, altitude',...
        ' geometric thickness and wavelength.', newline])
end

% Check to make sure re is the same length as the altitude vector

% first check to see if z_topBottom is a vector or a matrix
if size(z_topBottom,1)==1 || size(z_topBottom,2)==1
    % If true, then there must be two entries
    if length(z_topBottom)~=2
        error([newline,'Need two values for z_topBottom: altitude at cloud bottom top and cloud bottom', newline])
    end
    
    % make sure its a  column vector
    z_topBottom = reshape(z_topBottom,[],1);
    
elseif size(z_topBottom,1)>1 && size(z_topBottom,2)>1
    % if true, then there can only be two rows, and it must be equal in
    % size to the r matrix
    if size(z_topBottom,1)~=2
        error([newline,'Need two values for z_topBottom: altitude at cloud bottom top and cloud bottom', newline])
        
    elseif size(z_topBottom,2)~=size(re,2) || size(z_topBottom,2)==1
        error([newline,'z_topBottom must have the same number of columns as re, or a single column that is used for all wc files.', newline])
        
    end
    
end



if length(lambda)>1 && length(lambda)~=size(re,2)
    
    error([newline,'Lambda must be either a single value or a vector equal in legnth to the number of columns in re.', newline])
end

if length(tau_c)>1 && length(tau_c)~=size(re,2)
    
    error([newline,'The toptical depth must be either a single value or a vector equal in legnth to the number of columns in re.', newline])
end

if length(H)>1 && length(H)~=size(re,2)
    
    error([newline,'Cloud depth must be either a single value or a vector equal in legnth to the number of columns in re.', newline])
end


% Lets check to make sure the inputs re, tau_c and z are within the
% reasonble bounds

% -- Define the boundaries of interpolation for wavelength and radius --

wavelength_bounds = [100, 3000];            % nanometers - wavelength boundaries
r_eff_bounds = [1, 100];                    % microns - effective radius boundaries

% if lambda<wavelength_bounds(1) || lambda>wavelength_bounds(2)
%
%     error([newline, 'Wavelength is out of the range for Mie calculations. Must be between [0, 3000] nm.', newline])
%
% end
%
% if any(re<r_eff_bounds(1)) || any(re>r_eff_bounds(2))
%
%     error([newline, 're is out of the range for Mie calculations. Must be between [1, 100] microns.', newline])
%
% end

% Check to make sure the distribution string is one of two possible values

if strcmp(distribution_str, 'mono')==false && strcmp(distribution_str, 'gamma')==false
    
    error([newline,'I dont recognize the droplet distribution. Must be either "mono" or "gamma"', newline])
end



% Lets set up a few warnings incase the values of effective radius are
% outside the bounds of the Hu and Stamnes or Mie Interpolate
% parameterization
if ismatrix(re)==true
    if any(any(re<2.5)) || any(any(re>60))
        warning([newline, 'At least one value in r_{e} is outside the range of the Hu and Stamnes parameterization',newline,...
            'This is the default parameterization used to convert water cloud parameters to optical properites.',newline,...
            'The range of acceptable values for this parameterization is [2.5, 60] microns.',newline]);
    end
    
    if any(any(re>25))
        warning([newline,'At least one value in r_{e} is greater than 25 microns, which is the upper limit',...
            ' to the Mie Interpolate parameterization that computes optical properties from the water cloud ',...
            'parameters. The netcdf file downloaded from LibRadTrans website includes values of re up to',...
            ' 25 microns. The acceptable range for Mie Interpolation is [1, 25] micorns.',newline]);
    end
    
else
    
    if any(re<2.5) || any(re>60)
        warning([newline, 'At least one value in r_{e} is outside the range of the Hu and Stamnes parameterization',newline,...
            'This is the default parameterization used to convert water cloud parameters to optical properites.',newline,...
            'The range of acceptable values for this parameterization is [2.5, 60] microns.',newline]);
    end
    
    if any(re>25)
        warning([newline,'At least one value in r_{e} is greater than 25 microns, which is the upper limit',...
            ' to the Mie Interpolate parameterization that computes optical properties from the water cloud ',...
            'parameters. The netcdf file downloaded from LibRadTrans website includes values of re up to',...
            ' 25 microns. The acceptable range for Mie Interpolation is [1, 25] micorns.',newline]);
    end
    
end




% Determine which computer you're using
computer_name = whatComputer;

% Find the folder where the mie calculations are stored
% find the folder where the water cloud files are stored.
if strcmp(computer_name,'anbu8374')==true
    
    mie_calc_folder_path = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';
    water_cloud_folder_path = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/data/wc/';
    
elseif strcmp(computer_name,'andrewbuggee')==true
    
    mie_calc_folder_path = '/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';
    water_cloud_folder_path = '/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval/LibRadTran/libRadtran-2.0.4/data/wc/';
    
end

%%

% ------------------------------------------------------------
% ---------------------- COMPUTE LWC -------------------------
% ------------------------------------------------------------

% ----- I have to fudge the density of water ------
% This is the only way I can get my estimates of optical depth to match
% LibRadTrans estimates

%rho_liquid_water = 859900;              % grams/m^3 - density of liquid water
rho_liquid_water = 1e6;                 % grams/cm^3 - density of liquid water at 0 C



% --- STEP THROUGH COLUMNS OF re -----

if size(re,1)>1 && size(re,2)>1
    
    % We want to get all the mie properties we need before we loop through
    % the number of files
    
    num_files_2write = size(re,2);          % number of wc files to create
    
    
    
    % -------------------------------------------------------------------
    % ------ open the precomputed mie table and interpolate! ------------
    % -------------------------------------------------------------------
    
    % for writing water cloud files, we only need the extinction efficiency
    % Since this function is used often, we've created a file with just Q_ext
    
    justQ = true;                       % Load the precomputed mie table of only Q_ext values
    
    % lambda has to be the same size as re
    if length(lambda)==num_files_2write
        
        % remember that vectorizing a matrix (:) will stack column vectors
        % on top of one another
        
        lambda = reshape(lambda,1,[]); % each column represents a new file
        
        % create identical column vecotrs
        lambda = repmat(lambda,size(re,1),1);
        
        yq = interp_mie_computed_tables([lambda(:), re(:)], distribution_str, justQ);
        
    elseif length(lambda)==1
        
        yq = interp_mie_computed_tables([repmat(lambda,numel(re),1), re(:)], distribution_str, justQ);
        
    end
    
    
    
    
elseif size(re,1)==1 || size(re,2)==1
    
    num_files_2write = 1;
    
    % re must be a column vector
    re = reshape(re,[],1);
    
    % -------------------------------------------------------------------
    % ------ open the precomputed mie table and interpolate! ------------
    % -------------------------------------------------------------------
    
    % for writing water cloud files, we only need the extinction efficiency
    % Since this function is used often, we've created a file with just Q_ext
    
    justQ = true;                       % Load the precomputed mie table of only Q_ext values
    
    yq = interp_mie_computed_tables([repmat(lambda,numel(re),1), re], distribution_str, justQ);
    
    
else
    
    error([newline,'re is not a vector or a matrix! Check your inputs!', newline])
    
end

% grab the q extinction values

if justQ==false
    Qext = reshape(yq(:,5),[],num_files_2write);         % Extinction efficiency
else
    Qext = reshape(yq(:,3),[],num_files_2write);         % conver this back into a matrix corresponging to re
    
end


% now we will step through each wc file that needs to be created

% if H is a single value and num_files_2write is greater than 1, we will
% repeat it to create a vector with the same length
if length(H)==1 && num_files_2write>1
    H = repmat(H,num_files_2write,1);
end

% if tau_c is a single value and num_files_2write is greater than 1, we will
% repeat it to create a vector with the same length
if length(tau_c)==1 && num_files_2write>1
    tau_c = repmat(tau_c,num_files_2write,1);
end

if size(z_topBottom,2)==1 && num_files_2write>1
    z_topBottom = repmat(z_topBottom,1,num_files_2write);
end

% How many files are being created?
fileName = cell(1,num_files_2write);


% How many layers to model in the cloud?
nLayers = size(re,1)+1;             % Number of altitude levels we need to define a cloud
    
for nn = 1:num_files_2write
    
    
    % -------------------------------------------
    % ------ Create altitude vector! ------------
    % -------------------------------------------
    
    % the length of the altitude vector should be 1 unit longer than the length
    % of the effective radius. Thats because the last value in the altitude
    % vector is the altitude at cloud top, where the LWC has gone to zero
    
    
    % z must be a column vector
    z = linspace(z_topBottom(2,nn), z_topBottom(1,nn), nLayers)';                 % km - altitude vector
    
    
    % -------------------------------------------------------------------
    % ------------------- compute number concentration ------------------
    % -------------------------------------------------------------------
    
    % we need a number concentration for each file that is created
    
    if nLayers>1
        Nc = tau_c(nn)./(pi*trapz((z(1:end-1)-z(1))*1e3,Qext(:,nn).*(re(:,nn)*1e-6).^2));                % m^(-3) - number concentration
    else
        Nc = tau_c(nn)./(pi*(H(nn)*1e3)*Qext(nn).*(re*1e-6).^2);                            % m^(-3) - number concentration
        
    end
    
    % Compute Liquid Water Content
    
    lwc = 4/3 * pi * rho_liquid_water * (re(:,nn)*1e-6).^3 .* Nc;                    % g/m^3 - grams of water per meter cubed of air
    
    
    % Create the water cloud file name
    if length(re(:,nn))>1
        fileName{nn} = ['WC_rtop',num2str(round(re(end,nn))),'_rbot',num2str(round(re(1,nn))),'_T',num2str(tau_c(nn)),'_', distribution_str, '.DAT'];
    else
        fileName{nn} = ['WC_r',num2str(round(re)),'_T',num2str(round(tau_c)),'_', distribution_str, '.DAT'];
    end
    
    
    % ------------------------------------------------------------
    % ----------------- WE NEED TO APPEND ZEROS ------------------
    % ------------------------------------------------------------
    
    % Wherever the cloud is, there needs to be zeros at the cloud top altitude,
    % and below the cloud bottom altitude. This information tells LibRadTran
    % where the boundaries of the cloud are
    
    % both the effective radius and the LWC need zeros on either boundary,
    % unless if the cloud is at the surface
    
    if length(re(:,nn))==1
        
        if z_topBottom(2)==0
            % If true, then the cloud starts at the surface and we only append
            % zeros above the cloud
            re_2write = [re; 0];
            lwc_2write = [lwc; 0];
            z_2write = z;
            
        else
            % In this case, we need zeros below the cloud bottom, and at cloud
            % top
            z_2write = [0; z];                 % create a value at the surface where the cloud parameters go to zero
            re_2write = [0; re; 0];
            lwc_2write = [0; lwc; 0];
            
        end
        
    elseif length(re(:,nn))>1
        
        % Cloud top height defines the altitude where there is no cloud.
        
        % if the minimum z value is 0 then the cloud is at the surface
        if z_topBottom(2)==0
            % then we only append zeros above the cloud
            re_2write = [re; 0];
            lwc_2write = [lwc; 0];
            z_2write = z;
            
        else
            % Then we need zeros on either end
            z_2write = [0; z];
            re_2write = [0; re(:,nn); 0];
            lwc_2write = [0; lwc; 0];
            
        end
        
    end
    
    
    % ------------------------------------------------------------
    % ---------------------- WRITE WC FILE -----------------------
    % ------------------------------------------------------------
    
    
    
    % Create the water cloud file
    fileID = fopen([water_cloud_folder_path,fileName{nn}], 'w');
    
    % fprintf writes lines in our text file from top to botom
    % wc.DAT files are written with the higher altitudes at the top, and the
    % surface at the bottom
    
    % to write column vectors in a text file, we have to store them as row
    % vectors
    
    toWrite = [flipud(z_2write)'; flipud(lwc_2write)'; flipud(re_2write)'];
    
    % Create the opening comment lines of the WC.DAT file
    
    fprintf(fileID, '%s %10s %7s %8s \n','#','z','LWC','R_eff');
    fprintf(fileID, '%s %10s %7s %8s \n','#','(km)','(g/m^3)','(micron)');
    
    % Write in the data
    fprintf(fileID,'%12.3f %7.4f %8.3f \n', toWrite);
    fclose(fileID);
    
    
end


end
