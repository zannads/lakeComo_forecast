% This script has been developed starting from script_example.m provided in
% MATLAB_IterativeInputSelection_with_RTree-c, developed by Stefano Galelli
% and Riccardo Taormina
%
% Prof. Galelli is Assistant Professor, Singapore University of Technology
% and Design stefano_galelli@sutd.edu.sg
% http://people.sutd.edu.sg/~stefano_galelli/index.html
%
% Riccardo Taormina is a Ph.D. candidate at the Hong Kong Polytechnic
% University riccardo.taormina@connect.polyu.hk
% 
% For the script to work, the MATLAB_IterativeInputSelection_with_RTree-c
% must have been downloaded and added to MATLAB path, moreover the
% regression tree package source code must have been compiled, and the
% resulting mex files copied to the main directory. This directory must
% then be added to the MATLAB PATH. Refer to INSTALL.txt for further
% information on the steps to follow.

%% Set workspace
clear
clc
setup_params

%% Load and prepare data
ddp_solution = 86;
% I use my own function to produce the data to use in the script so as to
% change the minum amount of code possible.
c_v = dir( fullfile(raw_data_root, 'candidate_variables_99_18', '*.txt') );
%c_v = dir( fullfile(raw_data_root, 'perfect_inflows', '*.txt') );
c_v = fullfile({c_v.folder}', {c_v.name}'); 
% continue with standard candidate variables (states)
storage_file = fullfile( raw_data_root, 'ddp_trajectories_99_18', ['storage_sol', num2str(ddp_solution),'_99_18.txt'] );
doy_file = fullfile( raw_data_root, 'utils', 'doy_99_18_LD.txt' );

%output file
output_file = fullfile( raw_data_root, 'ddp_trajectories_99_18', ['release_sol', num2str(ddp_solution),'_99_18.txt'] );

%merge all the files into data matrix 
data = compact_files( [c_v;storage_file;doy_file;output_file] );

clear storage_file doy_file output_file
[~, c_v, ~] = fileparts(c_v); % rename c_v for print
c_v = [c_v; 'storage_t'; 'd_t']; % add the other candidate variables name;
%% Set the parameters for the Extra-Trees
M    = 500; % number of extra trees in the forest
nmin = 50;   % number of points per leaf
k    = size(data, 2)-1;  % Number of random cuts -> number of candidate variables
%k = 30;
%% Input ranking

% Shuffle the data
data_sh = shuffle_data(data);

% Run the ranking algorithm
[result_rank] = input_ranking(data_sh,M,k,nmin);

% Graphical analysis

% sort variables for bar plot
[temp,ixes] = sort(result_rank(:,2));
figure;
bar(result_rank(ixes,1));
xlabel('variable'); 
ylabel('normalized variable importance');
title('variable ranking - bar plot');

%% Multiple runs of the IIS algorithm (with different shuffled datasets)

% Define the parameters
ns = 8;         % number of folds
p  = 5;         % number of SISO models evaluated at each iteration 
epsilon  = 0;   % tolerance
max_iter = 5;   % maximum number of iterations

mult_runs = 5; % number of runs for the IIS algorithm               

% Run the IIS algorithm
results_iis_n = cell(1, mult_runs);
for i = 1:mult_runs
    fprintf( 'Run #%d\n',i );
    % Shuffle the data
    data_sh = shuffle_data(data);
    results_iis_n{i} = iterative_input_selection(data_sh,M,nmin,ns,p,epsilon,max_iter);
    clear data_sh 
end

% Plot the results
[X, R2] = visualize_inputSel(results_iis_n, max_iter, mult_runs, max_iter, 'Jet' );
print_names(c_v, X)

lst = dir( fullfile( raw_data_root, 'ivs_solutions', '*.mat' ) );
name = fullfile(raw_data_root, 'ivs_solutions', ['ivs_', num2str(length(lst)+1), '.mat'] );
eval( ['save ',name, ' c_v epsilon M max_iter nmin ns p R2 X'] ); 
clear lst name
% This code has been written by Stefano Galelli and Riccardo Taormina.
% Updated by Dennis Zanutto