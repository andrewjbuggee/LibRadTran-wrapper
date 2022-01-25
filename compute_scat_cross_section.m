%% ----- Compute the extinction cross section for a liquid water droplet -----

% wavelength has to be in microns, and is a vector
% r_eff is a vector of the same length as wavelength

% By Andrew J. Buggee
%%


function [ext_coeff] = compute_scat_cross_section(r_eff,wavelength,lwc)

% ensure that both inputs are positive
if sum(r_eff<0)>0
    error('the input, r_eff, is below 0, which is not allowed')
    
elseif sum(wavelength<0)>0
    error('the input, wavelength, is below 0, which is not allowed')
end


% ----- What computer are you using? -----

computer_name = whatComputer;

if strcmp(computer_name,'anbu8374')
    mie_fileName = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/data/wc/mie/wc.sol.mie.cdf';
elseif strcmp(computer_name,'andrewbuggee')
    error('I dont know where the file is!')
end

% ----- Read in the netcdf precomputed Mie tables from uvspec -----

ext = ncread(mie_fileName,'ext'); % km^(-1)/(g/m^3) - extinction coefficient
ssa = ncread(mie_fileName,'ssa');
reff = ncread(mie_fileName,'reff');
wavelen = ncread(mie_fileName,'wavelen');

% ------------------------------------------------------------------



%lwc = 0.2; % g/m^3 - liquid water content

% change units to m^(-1)
ext = ext.*lwc .*(1/1000); % m^(-1) - extinction coefficient

% ----- create mesh grids for wavelenth and effective radius grid for the lookup table ------

[W,R] = meshgrid(wavelen,reff);

% ----- create mesh grids for wavelenth and effective radius designated by the user ------

[Wq,Rq] = meshgrid(wavelength,r_eff);


% ----- If the user inputs are within the bounds of the pre-computed
% tables, we interpolate -----

index_r = r_eff>=min(reff) & r_eff<=max(reff);
index_w = wavelength>=min(wavelen) & wavelength<=max(wavelen);

length_r = length(r_eff);
length_w = length(wavelength);

if sum(index_r)==length_r && sum(index_w)==length_w
    % if ture, then we interpolate
    ext_coeff = interp2(W,R,ext,Wq,Rq);
    
else
    % if these conditions aren't true, we extrapolate
    ext_coeff = [];
    
end






end