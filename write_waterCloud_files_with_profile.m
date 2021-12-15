%% ----- Create wc.dat files with droplet profile -----

% this function writes .dat files for clouds with a specific droplet
% profile

% By Andrew J. Buggee
%%

function [newFile] = write_waterCloud_files_with_profile(r_top,r_bottom,tau_c,profile_type)

% determine what computer is being used in order to find the water cloud
% folder
computer_name = whatComputer;
if strcmp(computer_name,'andrewbuggee')==true
    
    oldFolder = ['/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/data/wc/'];
    
elseif strcmp(computer_name,'anbu8374')==true
    
    oldFolder = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/data/wc/';
    
end

% we save all water cloud files in the same locaiton as the template
newFolder = oldFolder;

% define the template that we will be editing
oldFile = 'file2Edit_profile';

% define the old expressions that will be edited
oldExpr = {'      2.000   1.0000  2.5000', '      2.100   1.0000  2.5000',...
    '      2.200   1.0000  2.5000', '      2.300   1.0000  2.5000',...
    '      2.400   1.0000  2.5000', '      2.500   1.0000  2.5000',...
    '      2.600   1.0000  2.5000', '      2.700   1.0000  2.5000',...
    '      2.800   1.0000  2.5000', '      2.900   1.0000  2.5000'};

% create a cell array that is the same length as oldExpr, since we create
% as many new expressions as there are old ones to replace
newExpr = cell(1,length(oldExpr));


% no matter the profile, we are create a droplet profile that extends 1 km,
% from the base of the cloud at 2km above the ground to the top of the
% cloud at 3 km above the ground
% we only define the values at the base of each layer
h = 900; % meters - cloud thickness
z0 = 2000; % meters - cloud base location
z = z0:100:(z0+h); % meters - the locations in geometric space that define the bottom of each layer within the cloud

if strcmp(profile_type,'adiabatic')
    
    % define the droplet profile for adiabatic behavior in geometric
    % coordniates (s.platnick 2000)
    
    b0 = r_bottom^3;
    b1 = r_top^3 - r_bottom^3;
    re_z = (b0 + b1 * (z-z0)./h).^(1/3); % droplet profile in geometric coordniate system for an adiabatic cloud
    
    % libRadTran requires liquid water content, but we want to enforce a
    % tau_c_str over the cloud. So we calculate what the total liquid water
    % content using the tau that was input by the user
    rho_liquid_water = 10^6; % grams/m^3 - density of liquid water
    lwc_top = 2/3 * rho_liquid_water * tau_c * (r_top/10^6)/h; % g/m^3 - total liquid water content, which is the value at the top of the cloud, since r is the largest
    
    % when we assume an adiabatic cloud, lwc varies linearly with geometric
    % height, z (lwc ~ z). We set a boundary condition at the base of the
    % cloud. Ideally this would be zero, but the boundary of clouds are
    % ambigious (s.platnick 2000)
    lwc_base = 0.001; % g/m^3 - boundary condition at the base of the cloud
    c0 = lwc_base;
    c1 = lwc_top;
    lwc = c0 + c1*(z-z0)./h; % g/m^3 - lwc profile as a function of geometric height
    
    % create the new file name
    r_bottom_round = round(r_bottom);
    r_top_round = round(r_top);
    tau_c_round = round(tau_c);
    
    r_bottom_str = num2str(r_bottom_round);
    r_top_str = num2str(r_top_round);
    tau_c_str = num2str(tau_c_round);
    
    if r_bottom_round<10 && r_top_round<10 && tau_c_round<10
        newFile = ['WC_profile_',profile_type,'_rbot0',r_bottom_str,'_rtop0',r_top_str,'_T0',tau_c_str,'.DAT'];
    elseif r_bottom_round<10 && r_top_round<10 && tau_c_round>=10
        newFile = ['WC_profile_',profile_type,'_rbot0',r_bottom_str,'_rtop0',r_top_str,'_T',tau_c_str,'.DAT'];
    elseif r_bottom_round<10 && r_top_round>=10 && tau_c_round<10
        newFile = ['WC_profile_',profile_type,'_rbot0',r_bottom_str,'_rtop',r_top_str,'_T0',tau_c_str,'.DAT'];
    elseif r_bottom_round<10 && r_top_round>=10 && tau_c_round>=10
        newFile = ['WC_profile_',profile_type,'_rbot0',r_bottom_str,'_rtop',r_top_str,'_T',tau_c_str,'.DAT'];
    elseif r_bottom_round>=10 && r_top_round<10 && tau_c_round<10
        newFile = ['WC_profile_',profile_type,'_rbot',r_bottom_str,'_rtop0',r_top_str,'_T0',tau_c_str,'.DAT'];
    elseif r_bottom_round>=10 && r_top_round<10 && tau_c_round>=10
        newFile = ['WC_profile_',profile_type,'_rbot',r_bottom_str,'_rtop0',r_top_str,'_T',tau_c_str,'.DAT'];
    elseif r_bottom_round>=10 && r_top_round>=10 && tau_c_round<10
        newFile = ['WC_profile_',profile_type,'_rbot',r_bottom_str,'_rtop',r_top_str,'_T0',tau_c_str,'.DAT'];
    elseif r_bottom_round>=10 && r_top_round>=10 && tau_c_round>=10
        newFile = ['WC_profile_',profile_type,'_rbot',r_bottom_str,'_rtop',r_top_str,'_T',tau_c_str,'.DAT'];
        
    end
    
    
    for xx = 1:length(oldExpr)
        % we need to make sure the new string length is identical to the
        % old one
        
        % lets create the LWC string
        % first lets check to see if there is a decimal point in our string
        num = round(lwc(xx),5);
        a = floor(num);
        b = num-a; % this tells us if our number is a fraction, or a whole number
        c = str2double(num2str(num)); % special case where num2str rounds up, but a is a whole integer diferrent
        
        if b==0
            newExpr_lwc = [num2str(num),'.0']; % if true, then there is no deicaml point in our string
        elseif (c-a)==1
            % if this is true, then we need to add a decimal point because
            % num2str rounded off and removed it
            newExpr_re = [num2str(num),'.0']; % if true, then there is no deicaml point in our string
        else
            
            newExpr_lwc = num2str(num);
        end
        
        % for LWC, we get 5 significant digits, or a string length of 6
        
        % --- check the length of the LWC string ---
        
        
        if length(newExpr_lwc)>1
            
            while length(newExpr_lwc)<6
                newExpr_lwc = [newExpr_lwc,'0'];
            end
            
            while length(newExpr_lwc)>6
                newExpr_lwc = newExpr_lwc(1:end-1);
            end
            
        elseif isempty(newExpr_lwc) == true
            error('String you are trying to write doesnt exist')
        end
        
        % lets check to make sure the LWC is within an acceptable range
        if str2double(newExpr_lwc)<0 || str2double(newExpr_lwc)>10
            
            disp([newline,'lwc_string value: ',newExpr_lwc,'. Layer: ',num2str(xx)])
            error('The value for lwc is either negative or far too large! Something happened when converting to a string')
        end
        
        % lets create the droplet size string
        % first lets check to see if there is a decimal point in our string
        num = round(re_z(xx),5);
        a = floor(num);
        b = num-a; % this tells us if our number is a fraction, or a whole number
        c = str2double(num2str(num)); % special case where num2str rounds up, but a is a whole integer diferrent
        if b==0
            newExpr_re = [num2str(num),'.0']; % if true, then there is no deicaml point in our string
        elseif (c-a)==1
            % if this is true, then we need to add a decimal point because
            % num2str rounded off and removed it
            newExpr_re = [num2str(num),'.0']; % if true, then there is no deicaml point in our string
            
        else
            
            newExpr_re = num2str(num);
        end
        
        
        
        % --- check the length of the droplet size string ---
        
        if length(newExpr_re)>1
            
            while length(newExpr_re)<6
                newExpr_re = [newExpr_re,'0'];
            end
            
            while length(newExpr_re)>6
                newExpr_re = newExpr_re(1:end-1);
            end
            
        elseif isempty(newExpr_re) == true
            error('String you are trying to write doesnt exist')
        end
        
        % quickly check the value, and make sure it is within the bounds of
        % the acceptable droplet sizes for the Hu and Stamnes
        % parameterization
        
        
        if str2double(newExpr_re)<2.5 || str2double(newExpr_re)>60
            
            disp([newline,'re_string value: ',newExpr_re,'. Layer: ',num2str(xx)])
            error('The value for r_e is too large! Something happened when converting to a string')
        end
        
        
        newExpr{xx} = [oldExpr{xx}(1:14),newExpr_lwc,'  ',newExpr_re];
        
    end
    
    % now that we have allocated all of the new values for LWC and re, we
    % can create a new water cloud file
    
    edit_INP_DAT_files(oldFolder,newFolder,oldFile,newFile,oldExpr,newExpr);
    
    
    
    
else
    
    error('I dont understand what kind of droplet profile you want')
    
end










end

