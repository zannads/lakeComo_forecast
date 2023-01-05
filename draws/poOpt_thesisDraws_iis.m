setup_params

%% Load and prepare data
ddp_solution = 86;
Res = false; %work on residual of BOP or not

% I use my own function to produce the data to use in the script so as to
% change the minum amount of code possible.
c_v = dir( fullfile(raw_data_root, 'candidate_variables_99_18', '*.txt') );
%c_v = dir( fullfile(raw_data_root, 'perfect_inflows', '*.txt') );
c_v = fullfile({c_v.folder}', {c_v.name}'); 
% continue with standard candidate variables (states)
storage_file = fullfile( raw_data_root, 'ddp_trajectories_99_18', ['level_sol', int2str(ddp_solution),'_99_18.txt'] );
doy_file = fullfile( raw_data_root, 'utils', 'doy_99_18_LD.txt' );

%output file
output_file = fullfile( raw_data_root, 'ddp_trajectories_99_18', ['release_sol', int2str(ddp_solution),'_99_18.txt'] );

%merge all the files into data matrix 
data = compact_files( [c_v;storage_file;doy_file;output_file] );

clear storage_file doy_file output_file ddp_solution Res
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

%% Input Ranking
% Shuffle the data
data_sh = shuffle_data(data);

% Run the ranking algorithm
[result_rank] = input_ranking(data_sh,rpar.M,rpar.k,rpar.nmin);

% Graphical analysis

% sort variables for bar plot
[~,ixes] = sort(result_rank(:,2));
IR_iis = figure;
bar(result_rank(ixes,1));
ax = gca;
ax(1).XAxis.FontSize = axFSize*2;
ax(1).YAxis.FontSize = axFSize*2;
xlabel('Variable number', 'FontSize', labFSize*2); 
ylabel('Normalized variable importance', 'FontSize', labFSize*2);
title('Input ranking - bar plot', 'FontSize', tFSize*1.5);
clear data_sh result_rank ixes ax
%%
% Define the parameters for the cross-validation
flag = 1; % if flag == 1, an ensemble is built on the whole dataset at the end of the cross-validation. 
          % Otherwise (flag == 0), such model is not built.

% Shuffle the data
data_sh = shuffle_data(data(:,end-2:end));
%%
% Run the cross-validation
[model] = crossvalidation_extra_tree_ensemble(data_sh,rpar.M,rpar.k,rpar.nmin,rpar.ns,flag);

% Model performance in calibration and validation
model.cross_validation.performance.Rt2_cal_pred_mean  % 
model.cross_validation.performance.Rt2_val_pred_mean  % 
%%
% Graphical analysis
cal_et = figure;
tiledlayout(2,1);
ax(1) = nexttile;
l(1) = plot(data_sh(1:7304,end),'.-'); 
hold on; 
l(2) = plot(model.complete_model.trajectories,'.-r'); grid on;
axis([1 length(data_sh) min(data_sh(:,end)) max(data_sh(:,end))]);
xlabel('Time','FontSize', labFSize*2); 
ylabel('Output','FontSize', labFSize*2);
legend(l, '$u_{[0,H]}^{POP,ref}$','$\hat{m} (d_t,h_{[0,H]}^{POP,ref})$', 'Interpreter', 'latex', 'FontSize', legFSize*1.5);
title('Calibration - Trajectory', 'FontSize',tFSize*1.5);
ax(1).XAxis.FontSize = axFSize*2;
ax(1).YAxis.FontSize = axFSize*2;
ax(2) = nexttile;
plot(model.complete_model.trajectories,data_sh(1:7304,end),'.'); grid on
axis([min(data_sh(:,end)) max(data_sh(:,end)) min(data_sh(:,end)) max(data_sh(:,end))]); 
xlabel('Measured','FontSize', labFSize*2); 
ylabel('Predicted','FontSize', labFSize*2);
title('Calibration - Scatter plot', 'FontSize', tFSize*1.5);
ax(2).XAxis.FontSize = axFSize*2;
ax(2).YAxis.FontSize = axFSize*2;

clear flag data_sh model ax l 
clear data rpar ans