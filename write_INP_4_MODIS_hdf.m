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

function [inpNames] = write_INP_4_MODIS_hdf(inputs,modis)

% for each spectral bin, we have an image on the ground composed of 2030 *
% 1354 pixels. The swath on the ground is large enough that the solar
% zenith and solar azimuth change significantly. Ideally at each spectral bin, and
% each pixel, we could calculate the reflectance function and how it varies
% with changing tau and change re.

re = inputs.re;
tau_c = inputs.tau_c;
bands2run = inputs.bands2run;
pixel_row = inputs.pixel_row;
pixel_col = inputs.pixel_col;

% a template file has been set up to be edited and saved as a new file
% determine which computer is being used
userName = whatComputer;

if strcmp(userName,'anbu8374')
    
    oldFolder = ['/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/MODIS_08_25_2021/'];
elseif strcmp(userName,'andrewbuggee')
    oldFolder = ['/Users/andrewbuggee/Documents/CU-Boulder-ATOC/',...
        'Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/MODIS_08_25_2021/'];
else
    error('I dont recognize this computer user name')
end
% Define where the new file should be saved
newFolder = oldFolder;

% we always edit the template file
oldFile = 'band_sza_saz_template.INP';


% lets determine the geometry of the pixel in question

sza = modis.solar.zenith(pixel_row,pixel_col);
saz = modis.solar.azimuth(pixel_row,pixel_col);

% we need the cosine of the zenith viewing angle
umu = round(cosd(double(modis.sensor.zenith(pixel_row,pixel_col))),3); % values are in degrees
phi = modis.sensor.azimuth(pixel_row,pixel_col);

% create the begining of the file name string
fileBegin = ['pixel_',num2str(pixel_row),'r_',num2str(pixel_col),'c_sza_',num2str(sza),'_saz_',num2str(saz),'_band_'];


% define the expressions that you wish to edit in the template file

oldExpr = {'wc_file 1D ../data/wc/WC_r04_T01.DAT', 'wavelength 0.00000 0.000000',...
    'sza 0000.0','phi0 0000.0','umu 0000.0','phi 0000.0'};

% some new expressions change in the for loop, and others are fixed like
% the geometry of the chosen pixel
% the new expressions have to be the same length. For geometry that means
% we always need 4 numerals and a decimal point

% lets fix the solar zenith angle first
str = ['sza ',num2str(sza),'.0'];

if length(str) < length(oldExpr{3})
    
    lengthDiff = length(oldExpr{3}) - length(str);
    for ii = 1:(lengthDiff) % the minus one accounts for the decimal point
        str = [str,'0'];
    end
    
elseif length(str) > length(oldExpr{3})
    
    error('new expression is greater than the old in expression in length')
    
end

newExpr{3} = str;

% now lets write the new solar azimuth angle. Modis defines the azimuth
% angle as [0,180] and [-180,0, whereas libradtran defines the azimuth
% angle as [0,360]. So we need to make this adjustment
if saz<0
    saz = saz+360;
end
str = ['phi0 ',num2str(saz),'.0'];

if length(str) < length(oldExpr{4})
    
    lengthDiff = length(oldExpr{4}) - length(str);
    for ii = 1:(lengthDiff) % the minus one accounts for the decimal point
        str = [str,'0'];
    end
    
elseif length(str) > length(oldExpr{4})
    
    error('new expression is greater than the old in expression in length')
    
end

newExpr{4} = str;

% now lets write the cosine of the zentih viewing angle. LibRadTran defines
% this as looking down on the earth, measuring upwelling radiation if umu>0
% and being on the earth looking up, measuring downwelling radition, if
% umu<0. If umu is 0, it implies a device looking horizontally. MODIS
% defines the sensor zenith angle to be between 0 and 180, where 0 is at
% zenith. This is equivelant to the libradtran method since cos(0)=1
% implies a device looking down. A sensor zenith of 180 implies looking up,
% and cos(180) = -1, which is the same definition libradtran uses.

if umu==1 || umu==-1 || umu==0
    str = ['umu ',num2str(umu),'.0'];
else
    str = ['umu ',num2str(umu)];
end

if length(str) < length(oldExpr{5})
    
    lengthDiff = length(oldExpr{5}) - length(str);
    for ii = 1:(lengthDiff) % the minus one accounts for the decimal point
        str = [str,'0'];
    end
    
elseif length(str) > length(oldExpr{5})
    
    % if the new string is greater than the old, we will assume there are
    % zeros at the end that can be delted, or that the extra precision is
    % not neccessary
    lengthDiff = length(str) - length(oldExpr{5});
    
    str = str(1:(end-lengthDiff));
    
    
end

newExpr{5} = str;

% now lets write the azimuth viewing angle. Modis defines the azimuth
% angle as [0,180] and [-180,0], whereas libradtran defines the azimuth
% angle as [0,360]. So we need to make this adjustment

if phi<0
    phi = phi+360;
end

str = ['phi ',num2str(phi),'.0'];

if length(str) < length(oldExpr{6})
    
    lengthDiff = length(oldExpr{6}) - length(str);
    for ii = 1:(lengthDiff) % the minus one accounts for the decimal point
        str = [str,'0'];
    end
    
elseif length(str) > length(oldExpr{6})
    
    error('new expression is greater than the old in expression in length')
    
end

newExpr{6} = str;



% step through each band, each effective raidus and each optical depth
inpNames = cell(length(re),length(tau_c),length(bands2run));

for kk = 1: length(bands2run)
    
    % create the new expression for the wavelength band of interest
    if kk<=2
        str = ['wavelength ',num2str(modis.EV.m250.bands.lowerBound(kk)),'.0 ',...
            num2str(modis.EV.m250.bands.upperBound(kk)),'.0'];
    elseif kk>2
        str = ['wavelength ',num2str(modis.EV.m500.bands.lowerBound(kk-2)),'.0 ',...
            num2str(modis.EV.m500.bands.upperBound(kk-2)),'.0'];
    end
    
    if length(str) < length(oldExpr{2})
        
        lengthDiff = length(oldExpr{2}) - length(str);
        for ii = 1:(lengthDiff) % the minus one accounts for the decimal point
            str = [str,'0'];
        end
        
    elseif length(str) > length(oldExpr{2})
        
        error('new expression is greater than the old in expression in length')
        
    end
    
    newExpr{2} = str;
    
    for ii = 1:length(re)
        for jj = 1:length(tau_c)
            
            % redefine the old file each time
            inpNames{ii,jj,kk} = [fileBegin,num2str(kk),'_r_',num2str(re(ii)),'_T_',num2str(tau_c(jj)),'.INP'];
            
            % lets define the new expressions to substitute the old ones
            
            if re(ii)<10 && tau_c(jj)<10
                newExpr{1} = ['wc_file 1D ../data/wc/WC_r0',num2str(re(ii)),'_T0',num2str(tau_c(jj)),'.DAT'];
                
            elseif re(ii)>=10 && tau_c(jj)<10
                newExpr{1} = ['wc_file 1D ../data/wc/WC_r',num2str(re(ii)),'_T0',num2str(tau_c(jj)),'.DAT'];
                
            elseif re(ii)>=10 && tau_c(jj)>=10
                newExpr{1} = ['wc_file 1D ../data/wc/WC_r',num2str(re(ii)),'_T',num2str(tau_c(jj)),'.DAT'];
                
            elseif re(ii)<10 && tau_c(jj)>=10
                newExpr{1} = ['wc_file 1D ../data/wc/WC_r0',num2str(re(ii)),'_T',num2str(tau_c(jj)),'.DAT'];
                
            end
            
            
            
            
            edit_INP_DAT_files(oldFolder,newFolder,oldFile,inpNames{ii,jj,kk},oldExpr,newExpr);
            
        end
    end
    
end




end





