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

% I use my own function to produce the data to use in the script so as to
% change the minum amount of code possible.
cv = dir( fullfile(raw_data_root, 'candidate_variables', '*.txt') );
cv = string(fullfile({cv.folder}', {cv.name}'));
output_file = string(fullfile( raw_data_root, 'release_sol85_99_18.txt' ) );
data = compact_files( [cv;output_file] );

%% Set the parameters for the Extra-Trees
M    = 500; % number of extra trees in the forest
nmin = 5;   % number of points per leaf
k    = size(data, 2)-1;  % Number of random cuts -> number of candidate variables
%% Input ranking

% Shuffle the data
data_sh = shuffle_data(data);

% Run the ranking algorithm
[result_rank] = input_ranking(data_sh,M,k,nmin);

% Graphical analysis

% sort variables for bar plot
[temp,ixes] = sort(result_rank(:,2))
figure;
bar(result_rank(ixes,1));
xlabel('variable'); 
ylabel('normalized variable importance');
title('variable ranking - bar plot');

%% Multiple runs of the IIS algorithm (with different shuffled datasets)

% Define the parameters
ns = 5;         % number of folds
p  = 5;         % number of SISO models evaluated at each iteration (this number must be smaller than the 
                % number of candidate inputs.
epsilon  = 0;   % tolerance
max_iter = 6;   % maximum number of iterations
                %
mult_runs = 10; % number of runs for the IIS algorithm               

% Run the IIS algorithm
for i = 1:mult_runs
    % Shuffle the data
    eval(['data_sh' '=' 'shuffle_data(data);']);
    eval(['result_iis_' num2str(i) '=' 'iterative_input_selection(data_sh,M,nmin,ns,p,epsilon,max_iter);']);
    eval(['results_iis_n{i} = result_iis_',num2str(i),';']);
    eval(['clear result_iis_', num2str(i)])
    clear data_sh 
end

% Plot the results
[X, R2] = visualize_inputSel(results_iis_n, max_iter, mult_runs, max_iter, 'Jet' );

% This code has been written by Stefano Galelli and Riccardo Taormina.
% Updated by Dennis Zanutto