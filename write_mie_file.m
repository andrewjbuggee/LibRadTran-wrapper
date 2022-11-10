%% This function will write a .INP file for a Mie calculation using libRadTran


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


% By Andrew John Buggee

%%

function [fileName] = write_mie_file(mie_program, index_refraction,re,wavelength, distribution_str, distribution_width, err_msg_str)

% ------------------------------------------------------------
% ---------------------- CHECK INPUTS ------------------------
% ------------------------------------------------------------

% Check to make sure there are 7 inputs


if nargin~=7
    error([newline,'Not enough inputs. Need 7: mie program type, index of refraction, droplet effective radius',...
        ' wavelength, droplet distribution type, distribution width, and the error message command.', newline])
end




if strcmp(distribution_str, 'mono')==false && strcmp(distribution_str, 'gamma')==false

    error([newline,'I dont recognize the droplet distribution. Must be either "mono" or "gamma"', newline])
end


if strcmp(mie_program, 'MIEV0')==false && strcmp(mie_program, 'BH')==false

    error([newline,'I dont recognize the mie program. Must be either "MIEV0" or "BH"', newline])
end

% Create the file name
fileName = ['Mie_calc_',distribution_str,'_distribution','.INP'];



% Determine which computer you're using
computer_name = whatComputer;

% Find the folder where the mie calculations are stored
% find the folder where the water cloud files are stored.
if strcmp(computer_name,'anbu8374')==true

    mie_calc_folder_path = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';

elseif strcmp(computer_name,'andrewbuggee')==true

    mie_calc_folder_path = '/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';

end

%%

% ------------------------------------------------------------
% ---------------------- WRITE MIE FILE -----------------------
% ------------------------------------------------------------

% Create comments for each line
comments = {'# Mie code to use', '# refractive index to use', '# specify effective radius grid (microns)',...
    '# Specify size distribution and distribution width','# Define wavelength boundaries (nanometers)',...
    '# Define interval of wavelength sampling', '# define output variables','# error file length'};

% Create the water cloud file
fileID = fopen([mie_calc_folder_path,fileName], 'w');

% fprintf writes lines in our text file from top to botom
% .INP files for mie calculations always require the same inputs

% to write column vectors in a text file, we have to store them as row
% vectors


% Define the mie program code to use

fprintf(fileID, '%11s %5s          %s \n','mie_program',mie_program,comments{1});


% check to see if the index of refraction is a string or a number
if isstring(index_refraction)==true || ischar(index_refraction)==true
    fprintf(fileID, '%6s %s          %s \n','refrac', index_refraction, comments{2});
elseif isnumeric(index_refraction)==true
    % if true we need a line for the real part and a line for the
    % imaginary part
    if isempty(real(index_refraction))==false
        fprintf(fileID, '%11s %f          %s \n','refrac_real', real(index_refraction), comments{2});
    end

    if isempty(imag(index_refraction))==false
        fprintf(fileID, '%11s %f          %s \n','refrac_imag', imag(index_refraction), comments{2});
    end


else

    error([newline,'I dont recognize the index of refraction input.',newline])
end


% Write in the value for the modal radius. Check to see if its a vector
if length(re)>1
    re_start = re(1);
    re_end = re(end);
    re_jump = re(2) - re(1);

    fprintf(fileID,'%5s %f %f %f          %s \n', 'r_eff', re_start, re_end, re_jump, comments{3});

elseif length(re)==1

    % there is only a single value for re
    fprintf(fileID,'%5s %3f          %s \n', 'r_eff', re, comments{3});

else

    error([newline, 'The input r_eff is an empty array', newline])

end


% Write in the value for the droplet distribution, if its not mono
if strcmp(distribution_str,'gamma')==true

    fprintf(fileID,'%12s %5s %f         %s \n', 'distribution', distribution_str, distribution_width, comments{4});

elseif strcmp(distribution_str,'lognormal')==true

    fprintf(fileID,'%12s %5s %f         %s \n', 'distribution', distribution_str, distribution_width, comments{4});

elseif strcmp(distribution_str,'mono')==true

    % if this is true, we don't need to write a distribution line

else

    error([newline, 'I dont recognize the distribution string.', newline])

end


% define the wavelength range

if length(wavelength)>1
    wavelength_start = wavelength(1);
    wavelength_end = wavelength(end);
    wavelength_jump = wavelength(2) - wavelength(1);

    fprintf(fileID,'%10s  %f %f          %s \n', 'wavelength', wavelength_start, wavelength_end, comments{5});
    fprintf(fileID,'%15s  %f          %s \n', 'wavelength_step', wavelength_jump, comments{6});

elseif length(wavelength)==1

    % there is only a single value for wavelength
    fprintf(fileID,'%10s  %f          %s \n', 'wavelength', wavelength, comments{5});

else

    error([newline, 'I think the wavelength vector is empty.', newline])

end


% Define the output variables
% But first make a comment
fprintf(fileID,'\n%s \n', comments{7});
fprintf(fileID,'%11s  %s %s %s %s %s %s %s %s \n', 'output_user','lambda', 'r_eff', 'refrac_real',...
    'refrac_imag', 'qext', 'omega', 'gg', 'qsca');


% Print the error message
fprintf(fileID, '%s          %s', err_msg_str, comments{8});


% Close the file!
fclose(fileID);


end



