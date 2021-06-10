%% --- Read Output Files from UVSPEC ---
% ======================================
% The purpose of this script is to read the data output from the output
% file created by uvspec. The code will determine the headers for each
% column of data, and the numerical values. Headers will be stored in the
% first row of a cell array. The data will be stored in the second row of
% the cell array.


% TO-DO:
%   1) The outputs are different if we choose to output transmittance or
%   transmissivity. What are the headers?

%   2) Test to see if the new structure writing works with multiple files.



% --- By Andrew J. Buggee ---
%% --- Read in Files ---

function [dataStruct,irrad_headers_units,rad_headers_units,irradianceData,radianceData] = readUVSPEC(path,fileName,inputSettings)

% How many files do we need to read?

if iscell(fileName)==true
    numFiles2Read = length(fileName);
elseif ischar(fileName)==true
    numFiles2Read = 1;
else
    error('I dont understand the input file')
end

% [fileName,path] = uigetfile('.txt');
delimeter = ' ';
headerLine = 0; % 0 if no header

data = [];

if numFiles2Read==1
    data = importdata([path,fileName],delimeter,headerLine);
    
elseif numFiles2Read>1
    
    for ii = 1:numFiles2Read
        
        data = cat(3,data,importdata([path,fileName{ii}],delimeter,headerLine));
        
    end
    
else
    
    error('There is something wrong with the number of files im supposed to read')
    
end

%% ----- Unpack the Input Settings -----

rte_solver = inputSettings{1};
umuVec = inputSettings{2};
phiVec = inputSettings{3};

numUmu = length(umuVec);
numPhi = length(phiVec);

%% ----- Pull out radiance and irradiance from the data table -----

% find the wavelength vector
% the first column include wavelength values as well as values for the
% cosine of the viewing angle, umu. umu has a range of [-1,1]. so to find
% wavelength values we just search for all values greater than 1.
col1 = data(:,1);
nonNanRows = sum(isnan(data),2)==0; % find rows where there are no nans
index150 = col1>150; % find values in the first column greater than 150
indexWave = logical(index150.*nonNanRows);
wavelength = col1(indexWave); % units of nanometers

% lets find the rows where the radiance data start. Each radiance data row
% will start with a umu value and end with either a positive number greater
% than 0 or a nan

% ---- There is a problem with the statement below! ----
% The umu values can have some overlap with the phi values. The most common
% one will be 0. One way to get around this is that phi values always come
% immediately after the wavelength values. So the umu values would have to
% be atleast 2 rows belows the wavelength row.

indexRadRow = ismember(col1,umuVec); % rows where radiance data begins


% Now we want to seperate the irradiance calculations from the radiance
% calcuations
indexNan_col1 = find(isnan(col1), 1); % what is this for?

if isempty(indexNan_col1)==true % I don't think this will ever be false
    
    % irradiance data only lies along rows that start with a wavelength
    indexIrradiance = repmat(indexWave,1,size(data,2));
    
    irradianceData = data(indexIrradiance);
    irradianceData = reshape(irradianceData,length(wavelength),size(data,2));
    
    % When the radiance data begins, we have two values to start with: the
    % umu value and the u0u value. So we need to add 2 to the number of phi
    % angles we are calculating to get the total length of our radiance
    % vector
    if rem(numPhi+2,size(data,2))==0
        
        % if this is true, there are non NaNs and we dont need to worry
        % about extra rows
        indexRadRow = repmat(indexRadRow,1,size(data,2));
        
        radianceData = data(indexRadRow);
        radianceData = reshape(radianceData,sum(indexRadRow(:,1)),[]);
        
        
    elseif floor((numPhi+2)/size(data,2))==0
        
        % if this is true, there are NaNs but we don't need to worry about
        % extra rows
        indexRadRow = repmat(indexRadRow,1,size(data,2));
        
        % we need to get rid of the NaNs so we can easily recover the order
        % of the data table
        data(isnan(data))=0;
        
        radianceData = data(indexRadRow);
        radianceData = reshape(radianceData,sum(indexRadRow(:,1)),[]);
        radianceData(:,(numPhi+2+1):end) = [];
    else
        % if this is true, there are NaNs to account for, and there are
        % rows of data after each logical 1 in indexRadRow that we need to
        % add to our logical index
        
        indexRadRow(find(indexRadRow)+1) = 1; % this adds a 1 to every row after a 1, since we need the row below
        indexRadRow = repmat(indexRadRow,1,size(data,2));
        
        data(isnan(data))=0;
        radianceData = data(indexRadRow);
        radianceData = reshape(radianceData,sum(indexRadRow(:,1)),[]);
        radianceData = reshape(radianceData',[],size(radianceData,1)/2)';
        radianceData(:,(numPhi+2+1):end) = [];
    end
    
else
    
    error('There is a NaN in the first column of the data import!')
    
end




%% --- Converstion to a Structure ---

% if the RTE solver is disort, sdisort, or spsdisort, it has the following
% outputs
%   1) lambda - wavelength of light. Units: nanometers

%   2) edir - direct beam irradiance w.r.t horizontal plane, which is the
%   unscattered light that reaches the ground. For a flux F, the
%   transmission from space to ground can be defined as F/F0 = exp(-tau).
%   Therefore the direct beam irradiance is the fraction of light that
%   made it through a medium without scattering or absorption:
%   F = F0 exp(-tau). Units: (mW/m^2/s)

%   3) edn - diffuse down irradiance (total minus direct beam). This is the
%   fraction of irradiance that was scattered or absorbed by the traversed
%   medium (1 - exp(-tau)) but eventually made it down to the ground.
%   Units: (mW/m^2/s)

%   4) eup - diffuse up irradiance. This the scattered, emitted light
%   that is moving upwards at the surface of the earth. It is a fraction of
%   the absorbed or scattered light (1 - exp(-tau)) that returns back to
%   space, rather than moves towards the ground. Likely single + multiple
%   scattering accounted for. Units: (mW/m^2/s)

%   5) uavgdir - Direct beam contribution to the mean intensity. Peter
%   believes this is referring to the actinic flux, which is the flux
%   attenuated in the atmosphere at some angle. Its usually in units of
%   photons/area/sec but for UVSPEC its provided in units of
%   milli-Watts/m^2/sec. Its a similar product as flux, which only accounts
%   for the portion of light normal to some refernce sureface. Actinic
%   flux doesn't have the reference plane. Units: (mW/m^2/s).

%   6) uavgdn - Diffuse downward radiation contribution to the mean
%   intesntiy. It is the diffuse portion of quantity (5). So it is the mean
%   intensity (actinic flux) that reaches the ground after a scattering or
%   absorption event. Units: (mW/m^2/s)

%   7) uavgup - Diffuse upward radiation contribution to the mean intenstiy
%   - This is the upward actinic flux after some scattering or absorption
%   event. Units: (mW/m^2/s).

%   8) uu - Radiance - If umu is specified, where umu is the cosine of the
%   zenith viewing angle, and phi is specified, where phi is the sensor
%   azimuth, then uu is the radiance at umu and phi. When specifying these
%   two angles, it is important to also include the solar aziumuth angle,
%   phi0. Remember radiances are for specific look angles. Note: if umu is
%   not specified, uvspec defaults to a zenith viewing angle of 0; umu>0
%   means sensors looking downward (i.e. satellite), and umu<0 means
%   looking upward; phi=phi0 means sensor is looking into direction of the
%   sun; phi-phi0=180 means the sun is in back of the sensor.
%   Units: (mW/m^2/sr/s)


%   9) u0u - Azimuthally averaged Radiance - If umu is specified, where
%   umu is the cosine of the zenith viewing angle,then u0u is the
%   azimuthally averaged radiance at umu angles. Units: (mW/m^2/sr/s)


% we want an array ouput of the irradiance and radiance data for wasy
% analysis, and we want a structure output for easy manipulation on the fly



if strcmp(rte_solver,'disort')==true
    
    irrad_headers_units = cell(2,8);
    irrad_headers_units{1,1} = 'wavelength';
    irrad_headers_units{1,2} = 'dirIrrad';
    irrad_headers_units{1,3} = 'difDwnIrrad';
    irrad_headers_units{1,4} = 'difUpIrrad';
    irrad_headers_units{1,5} = 'dirContMeanIrrad';
    irrad_headers_units{1,6} = 'difDwnContMeanIrrad';
    irrad_headers_units{1,7} = 'difUpContMeanIrrad';
    irrad_headers_units{2,1} = 'nm';
    irrad_headers_units{2,2} = 'mW/(m^{2} nm)';
    irrad_headers_units{2,3} = 'mW/(m^{2} nm)';
    irrad_headers_units{2,4} = 'mW/(m^{2} nm)';
    irrad_headers_units{2,5} = 'mW/(m^{2} nm)';
    irrad_headers_units{2,6} = 'mW/(m^{2} nm)';
    irrad_headers_units{2,7} = 'mW/(m^{2} nm)';
    
    % Using these default outputs, we will want the following additional
    % outputs
    irrad_headers_units{1,8} = 'totDwnIrrad';
    irrad_headers_units{2,8} = 'mW/(m^{2} nm)';
    
    if numFiles2Read==1
        irradianceData = [irradianceData,irradianceData(:,2)+irradianceData(:,3)];
        
    elseif numFiles2Read>1
        irradianceData = cat(2,irradianceData,irradianceData(:,2,:) + irradianceData(:,3,:));
        
    end
    
    
    % and now we'll create the structure
    % we'll start by creating the wavelength vector
    
    
    
    if numFiles2Read==1
        if numUmu==0
            % if we have to zenith view angles, then only irradiance is
            % calculated
            
            dataStruct = struct(irrad_headers_units{1,2},data(:,2),...
                irrad_headers_units{1,3},data(:,3),irrad_headers_units{1,4},data(:,4),...
                irrad_headers_units{1,5},data(:,5),irrad_headers_units{1,6},data(:,6),...
                irrad_headers_units{1,7},data(:,7),irrad_headers_units{1,8},data(:,8));
            
            dataStruct.wavelength = wavelength;
            
        elseif numUmu>0
            % if we do have zenith viewing angles defined, then uvspec
            % calculates both irradiance and radiance
            
            rad_headers_units = cell(2,2);
            rad_headers_units{1,1} = 'azAvgRad';
            rad_headers_units{1,2} = 'rad-umu-phi';
            rad_headers_units{2,1} = 'mW/(m^{2}/sr/s)';
            rad_headers_units{2,2} = 'mW/(m^{2}/sr/s)';
            
            dataStruct = struct('irradiance',struct(irrad_headers_units{1,2},irradianceData(:,2),...
                irrad_headers_units{1,3},irradianceData(:,3),irrad_headers_units{1,4},irradianceData(:,4),...
                irrad_headers_units{1,5},irradianceData(:,5),irrad_headers_units{1,6},irradianceData(:,6),...
                irrad_headers_units{1,7},irradianceData(:,7),irrad_headers_units{1,8},irradianceData(:,8)));
            
            dataStruct.wavelength = wavelength;
            dataStruct.radiance(1).geometry = 'umu,phi'; % format of the geometry for each vector
            
            % now we need the index for constant geometry but changing
            % wavelength
            
            
            for jj = 1:numPhi
                for kk = 1:numUmu
                    ind = sub2ind([numUmu,numPhi],kk,jj);
                    dataStruct.radiance(ind+1).geometry = [num2str(umuVec(kk)),',',num2str(phiVec(jj))];
                    
                    indexCol = 2 + jj; % The first two colums contain stuff we currently don't care about like the umu value and the azimuthally averaged radiance
                    indexRow = kk:numUmu:size(radianceData,1);
                    
                    dataStruct.radiance(ind).rad_umu_phi = radianceData(indexRow,indexCol); % this gives us vectors of constant geometry but changing wavelength
                    
                     
                end
            end
            
            
        end
        
        
        
    elseif numFiles2Read>1
        dataStruct = struct(irrad_headers_units{1,1},reshape(data(:,1,:),[],numFiles2Read),...
            irrad_headers_units{1,2},reshape(data(:,2,:),[],numFiles2Read),irrad_headers_units{1,3},...
            reshape(data(:,3,:),[],numFiles2Read),irrad_headers_units{1,4},...
            reshape(data(:,4,:),[],numFiles2Read),irrad_headers_units{1,5},...
            reshape(data(:,5,:),[],numFiles2Read),irrad_headers_units{1,6},...
            reshape(data(:,6,:),[],numFiles2Read),irrad_headers_units{1,7},...
            reshape(data(:,7,:),[],numFiles2Read),irrad_headers_units{1,8},...
            reshape(data(:,8,:),[],numFiles2Read));
    end
    
elseif strcmp(rte_solver,'twostr')==true
    
    irrad_headers_units = cell(2,6);
    irrad_headers_units{1,1} = 'wavelength';
    irrad_headers_units{1,2} = 'dirIrrad';
    irrad_headers_units{1,3} = 'difDwnIrrad';
    irrad_headers_units{1,4} = 'difUpIrrad';
    irrad_headers_units{1,5} = 'dirContMeanIrrad';
    irrad_headers_units{2,1} = 'nm';
    irrad_headers_units{2,2} = 'mW/(m^{2} nm)';
    irrad_headers_units{2,3} = 'mW/(m^{2} nm)';
    irrad_headers_units{2,4} = 'mW/(m^{2} nm)';
    irrad_headers_units{2,5} = 'mW/(m^{2} nm)';
    
    % Using these default outputs, we will want the following additional
    % outputs
    
    data = [data,data(:,2)+data(:,3)];
    irrad_headers_units{1,6} = 'totDwnIrrad';
    irrad_headers_units{2,6} = 'mW/(m^{2} nm)';
    
    % and now we'll create the structure
    
    dataStruct = struct(irrad_headers_units{1,1},data(:,1),irrad_headers_units{1,2},data(:,2),...
        irrad_headers_units{1,3},data(:,3),irrad_headers_units{1,4},data(:,4),...
        irrad_headers_units{1,5},data(:,5),irrad_headers_units{1,6},data(:,6));
    
    
    
else
    error('Dont recognize rte solver')
    
    
end




end

