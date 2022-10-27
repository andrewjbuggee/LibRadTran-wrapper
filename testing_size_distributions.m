%% Lets compare the monodispersed distribution with the gamma droplet distribution

wl = 550;                       % nanometers
r = 1:100;                   % microns

mono = interp_mie_computed_tables([linspace(wl,wl,length(r))', r'], 'mono',false);


Gamma = interp_mie_computed_tables([linspace(wl,wl,length(r))', r'], 'gamma',false);

figure; subplot(1,3,1); plot(r,mono(:,5),r,Gamma(:,5));title('$Q_e$ using Wiscombe code','Interpreter','latex'); grid on; grid minor
xlabel('$r_{eff}$ ($\mu m$)','Interpreter','latex'); ylabel('$Q_e$','Interpreter','latex'); legend('monodispersed','gamma distribution')

subplot(1,3,2); plot(r,mono(:,6),r,Gamma(:,6)); title('$\tilde{\omega}$ using Wiscombe code','Interpreter','latex'); grid on; grid minor
xlabel('$r_{eff}$ ($\mu m$)','Interpreter','latex'); ylabel('$\tilde{\omega}$','Interpreter','latex');

subplot(1,3,3); plot(r,mono(:,7),r,Gamma(:,7)); title('$g$ using Wiscombe code','Interpreter','latex'); grid on; grid minor
xlabel('$r_{eff}$ ($\mu m$)','Interpreter','latex'); ylabel('$g$','Interpreter','latex')


%% Lets run the Bohren and Huffman mie code for mono dispersed particles, gamma particles and log-normal particles


% Running bohren and Huffman for monodispersed
folderName = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';
inputName = 'Mie_calcs_monodispersed_BH.INP';
outputName = 'OUTPUT_Mie_calcs_monodispersed_BH';
[drop_settings] = runMIE(folderName,inputName,outputName);
[BH_mono,~,~] = readMIE(folderName,outputName);



% Running bohren and Huffman for gamma distribution
folderName = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';
inputName = 'Mie_calcs_gamma7_BH.INP';
outputName = 'OUTPUT_Mie_calcs_gamma7_BH';
[drop_settings] = runMIE(folderName,inputName,outputName);
[BH_gamma,~,~] = readMIE(folderName,outputName);


% Running bohren and Huffman for lognormal distribution
folderName = '/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/Mie_Calculations/';
inputName = 'Mie_calcs_logNormal_1_7_BH.INP';
outputName = 'OUTPUT_Mie_calcs_logNormal_1_7_BH';
[drop_settings] = runMIE(folderName,inputName,outputName);
[BH_logNorm,~,~] = readMIE(folderName,outputName);


% lets make a plot

r = 1:100;
wl = 550;   % nanometers

index = BH_mono.wavelength == wl;

figure; 
subplot(1,3,1); semilogy(r,BH_mono.Qext(index,:),r,BH_gamma.Qext(index,:),r,BH_logNorm.Qext(index,:));
title('$Q_e$ using BH code','Interpreter','latex'); grid on; grid minor
xlabel('$r_{eff}$ ($\mu m$)','Interpreter','latex'); ylabel('$Q_e$','Interpreter','latex'); legend('monodispersed','gamma','log normal')

subplot(1,3,2); plot(r,BH_mono.ssa(index,:),r,BH_gamma.ssa(index,:),r,BH_logNorm.ssa(index,:)); 
title('$\tilde{\omega}$ using BH code','Interpreter','latex'); grid on; grid minor
xlabel('$r_{eff}$ ($\mu m$)','Interpreter','latex'); ylabel('$\tilde{\omega}$','Interpreter','latex');

subplot(1,3,3); plot(r,BH_mono.asymParam(index,:),r,BH_gamma.asymParam(index,:),r,BH_logNorm.asymParam(index,:)); 
title('$g$ using BH code','Interpreter','latex'); grid on; grid minor
xlabel('$r_{eff}$ ($\mu m$)','Interpreter','latex'); ylabel('$g$','Interpreter','latex')





%% Attempting to solve for the single scattering albedo for a droplet distribution

% define the wavelength of interest
wl = 550;   % nanometers

index = BH_mono.wavelength == wl;

% For some effective radius, we have defined a droplet size distribution
% ----- for a gamma distribution -----

r_eff = 1:100;                                              % microns
r = linspace(1, 100, 100);                  % microns - vector based on C.Emde (2016)
alpha = 7;
mu = alpha+3;                                            % to ensure I have the correct gamma distribution

ssa_avg = zeros(1,length(r_eff));
Qe_avg = zeros(1, length(r_eff));

for ii = 1:length(r_eff)

    b = mu/r_eff(ii);                                   % exponent parameter
    N = mu^(mu+1)/(gamma(mu+1) * r_eff(ii)^(mu+1));  % normalization constant

    n_r = N*r.^mu .* exp(-b*r);                            % gamma droplet distribution



    % according to C.Emde (2016) page 1665, the average single scattering
    % albedo over a droplet distribution is:

    ssa_avg(ii) = trapz(r, (pi*r.^2) .* (BH_mono.ssa(index,:)) .* (BH_mono.Qext(index,:) .* (n_r)))./...
        trapz(r, (pi*r.^2) .* (BH_mono.Qext(index,:) .* (n_r)));

  
    Qe_avg(ii) = trapz(r, (BH_mono.Qsca(index,:)) .* n_r)./trapz(r, BH_mono.ssa(index,:) .* n_r);

end




figure; plot(r, BH_mono.Qext(index,:));
hold on; plot(r_eff, Qe_avg,'k-')
title('$Q_e$ using BH code','Interpreter','latex'); grid on; grid minor
xlabel('$r_{eff}$ ($\mu m$)','Interpreter','latex'); ylabel('$Q_e$','Interpreter','latex'); legend('monodispersed','my gamma avg')