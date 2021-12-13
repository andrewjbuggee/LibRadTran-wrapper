% --- Add Folders to Path specific to this computer -----

computer_name = whatComputer;

if strcmp(computer_name,'anbu8374')==true
% LibRadTran Data Folders
addpath('/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/data/solar_flux/');
addpath('/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/data/wc/');
addpath('/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/data/albedo/');
addpath('/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/data/altitude/');
addpath('/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/data/atmmod/');
addpath('/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/data/correlated_k/');

% LibRadTran Bin folder
addpath('/Users/anbu8374/Documents/LibRadTran/libRadtran-2.0.4/bin/');

elseif strcmp(computer_name,'andrewbuggee')==true
    
addpath('/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/data/solar_flux/');
addpath('/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/data/wc/');
addpath('/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/data/albedo/');
addpath('/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/data/altitude/');
addpath('/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/data/atmmod/');
addpath('/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/data/correlated_k/');

% LibRadTran Bin folder
addpath('/Users/andrewbuggee/Documents/CU-Boulder-ATOC/Hyperspectral-Cloud-Droplet-Retrieval-Research/LibRadTran/libRadtran-2.0.4/bin/');

end

    