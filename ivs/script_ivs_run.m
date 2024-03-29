% This script has been developed starting from script_example.m provided in
% MATLAB_IterativeInputSelection_with_RTree-c, developed by Stefano Galelli
% and Riccardo Taormina
%
% For the script to work, the MATLAB_IterativeInputSelection_with_RTree-c
% must have been downloaded and added to MATLAB path, moreover the
% regression tree package source code must have been compiled, and the
% resulting mex files copied to the main directory. This directory must
% then be added to the MATLAB PATH. Refer to INSTALL.txt for further
% information on the steps to follow.
% Moreover, the downloaded MATLAB package should be my modified version.
% Available at https://github.com/zannads/MATLAB_IterativeInputSelection_with_Rtree-c.git

%% Set workspace
%clear
%clc
setup_base;

%% Load and prepare data
ddp_solution = 86;
Res = false; %work on residual of BOP or not

% I use my own function to produce the data to use in the script so as to
% change the minum amount of code possible.
c_v = dir( fullfile(data_folder, 'candidate_variables_99_18', '*.txt') );
%c_v = dir( fullfile(data_folder, 'perfect_inflows', '*.txt') );
c_v = fullfile({c_v.folder}', {c_v.name}'); 
% continue with standard candidate variables (states)
storage_file = fullfile( data_folder, 'Solutions', 'DDP', ['level_sol', int2str(ddp_solution),'_99_18.txt'] );
doy_file = fullfile( data_folder, 'LakeComoRawData', 'utils', 'doy_99_18_LD.txt' );

%output file
output_file = fullfile( data_folder, 'Solutions', 'DDP', ['release_sol', int2str(ddp_solution),'_99_18.txt'] );

%merge all the files into data matrix 
data = compact_files( [c_v;storage_file;doy_file;output_file] );

clear storage_file doy_file output_file
[~, c_v, ~] = fileparts(c_v);    % rename c_v for print
c_v = [c_v; 'storage_t'; 'd_t']; % add the other candidate variables name;

%% Set the parameters for the Extra-Trees and the IIS
% extra tree
rpar.M    = 500; % number of extra trees in the forest
rpar.nmin = 15;   % number of points per leaf
rpar.k    = size(data, 2)-1;  % Number of random cuts -> number of candidate variables

% IIS
rpar.ns = 8;         % number of folds
rpar.p  = 7;         % number of SISO models evaluated at each iteration 
rpar.epsilon  = 0;   % tolerance
rpar.max_iter = 5;   % maximum number of iterations

rpar.mult_runs = 5; % number of runs for the IIS algorithm               

%% Multiple runs of the IIS algorithm (with different shuffled datasets)

% Run the IIS algorithm
%results_iis_n = cell(1, rpar.mult_runs);
clear results_iis_n
if Res 
    %fit variable for working on the residual or not
    % storage and doy last 2
    fit =  [length(c_v)-1, length(c_v)];
else
    fit = [];
end

for i = 1:rpar.mult_runs
    fprintf( 'Run #%d\n',i );
    % Shuffle the data
    data_sh = shuffle_data(data);
    results_iis_n(i) = iterative_input_selection(data_sh,rpar, 1, fit, 'Name', c_v);
    clear data_sh 
end

% Plot the results
[X, R2, R2_res] = summarize_IIS_result(results_iis_n);
print_names(c_v, X)
%print_R2( R2, X, c_v )
%draw_colorMap( X, R2 )

%% saving 

for i = 1:rpar.mult_runs
    for k = 1:results_iis_n(i).iters_valid
        results_iis_n(i).iter(k).MISO = rmfield( results_iis_n(i).iter(k).MISO, 'complete_model' );
    end
end

if Res
    base = 'ivsRes_';
else
    base = 'ivs_';
end
name = fullfile(data_folder, 'Solutions', 'IVS', strcat('sol', int2str(ddp_solution)), ...
    strcat(base,code,'_sol',int2str(ddp_solution),'_n', int2str(rpar.nmin), '.mat') );
% if exist( name, 'file' )
%     name(end-3:end+2) = '_2.mat';
% end
save( name, 'c_v', 'rpar', 'results_iis_n' );
clear name i k iterS X R2 R2_res 
% This code has been written by Dennis Zanutto