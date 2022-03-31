%% This function will create a cloud droplet profile based on one of four
% physical assumptions. These are taken from S.Platnick's 2000 paper

% INPUTS:
%   (1) re_top_bottom - effective droplet radius (microns) - these are the
%   boundary values for the profile you wish to create. You enter them as
%   a vector in the order specified by the variable name [re_top,
%   re_bottom]. 

%   (2) z or tau - the vertical independent variable, which is either
%   geometric altitude or optical depth. If using geometric altitude (z),
%   this variable should be defined in units of kilometers. 

%   (3) 'altitude' or 'optical_depth' - the string that tells the code the
%   vertical indepdendent variable is either geometric altitude or optical
%   depth

%   (4) constraint - the physical constraint (string) - there are four
%   different string options for a physical constraint:
%       (a) 'adiabatic' - this assumption forces the liquid water content to
%       be proportionl to z, the altitude. 
%       (b) 'subadiabatic aloft' - this assumption assumes there is
%       increasing entrainment and drying towards the cloud top.
%       (c) 'linear_with_z' - this constraint forces the effective droplet profile
%       to behave linearly with z (re(z)~z). Physically we are forcing subadiabtatic
%       behavior at mid-levels.
%       (d) 'linear_with_tau' - this constraint forces the effective
%       droplet radius to have linearly with optical depth (re(z)~tau).
%       Physically, this too forces subadiabatic behavior at mid-levels.

% OUTPUTS:
%   (1) re - effective droplet radius profile


% By Andrew John Buggee
%%

function re = create_droplet_profile2(re_top_bottom,zT, independentVariable, constraint)



% The boundary values are altered using a powerlaw to get the constraint we
% want
    % boundary conditions for r as a function of tau
    a0 = r_top^(2*x + 3/x);
    a1 = r_top^(2*x + 3/x) - r_bottom^(2*x + 3/x);
    

a0 = @(x) re_top_bottom(1)^(2*x + 3/x);
a1 = @(x) re_top_bottom(1)^(2*x + 3/x) - re_top_bottom(2)^(2*x + 3/x);

    % boundary conditions for r as a function of z
    
    b0 = @(x) re_top_bottom(2)^(x/3);
    b1 = @(x) re_top_bottom^(x/3) - re_top_bottom^(x/3);

if strcmp(constraint,'subadiabatic_aloft')
    
    % if the profile chosen is subadiabatic aloft, then 0<x<1
    x = 1/2;
    
    % create the droplet profile
    if strcmp(independentVariable, 'altitude')
        
    elseif strcmp(independentVariable, 'optical_depth')
        
    else
        error([newline,'Vertical variable is unrecognizable. Only "altitude" and "optical_depth" are accepted.',newline])
    end
    
    
elseif strcmp(profile_type,'adiabatic')
    
        % if the profile chosen is adiabatic, then x=1
    x = 1;
    
    % boundary conditions for r as a function of tau
    a0 = r_top^(2*x + 3/x);
    a1 = r_top^(2*x + 3/x) - r_bottom^(2*x + 3/x);
    
    % boundary conditions for r as a function of z
    
    b0 = r_bottom^3;
    b1 = r_top^3 - r_bottom^3;
    
    % Boundary conditions for LWC as a function of z
    
    % Lets step through each pixel according to data_inputs, and compute
    % the profile for a given r_bottom, r_top, and tau_c
    
    for ii = 1:length(tau_c)
        T = linspace(0,tau_c(ii),num_query_points);
        r_tau(ii,:) = (a0 - a1*(T./tau_c(ii))).^(1/(2*x + 3/x));
        r_z(ii,:) = (b0 + b1 * (z-z0)./h).^(x/3);                      % droplet profile in geometric coordniate system for an adiabatic cloud
        
        % ----------------------- ASSUMPTION ----------------------
        % We assume the number concentration is constant with heighy
        % ---------------------------------------------------------
        
        % First lets compute the extinction efficient
        % Lets assume a monodispersed distribution
        yq = interp_mie_computed_tables([linspace(wl_tau, wl_tau,num_query_points)',r_z(ii,:)'],'mono');
        
        Qext = yq(:,5);                                                                          % Extinction efficiency
        Nc(ii) = tau_c(ii)/(pi*trapz((z-z0),Qext'.*(r_z(ii,:)*1e-6).^2));                                     % m^(-3) - number concentration
        
        lwc_z(ii,:) = 4/3 * pi * rho_l * r_z(ii,:).^3 * Nc(ii);
    end
    
    
elseif strcmp(profile_type,'subadiabatic_midlevel')
    
    % if the profile chosen is subadiabatic aloft, then is either 3 or -3
    x = 3;
    
    a0 = r_top^(2*x + 3/x);
    a1 = r_top^(2*x + 3/x) - r_bottom^(2*x + 3/x);
    
    for ii = 1:length(tau_c)
        T = linspace(0,tau_c(ii),num_query_points);
        r_tau(ii,:) = (a0 - a1*(T./tau_c(ii))).^(1/(2*x + 3/x));
    end    
    
    
else
    
    error('I dont recognize the droplet profile you want!')
    
end




end
