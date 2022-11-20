% ddp_sol_format generates an array of struct ddpsol with the following
% field, each element in the array corresponds to a weighted solution of
% the ddp problem:
%       J           horizontal array with cost function result.
%       weight      horizontal array with the weights.
%       flag_vr     value that tells if the solution breaks the speed
%                   operation constraint for the bulkheads of Lake Como.
%       flag_ref    value that indicates if the solution is in the
%                   reference set and eventually its index.
%       sim_h       vertical array with the whole simulation period: level.
%       sim_r       vertical array with the whole simulation period: release.

%input to the file: 
%       JJJ [N_obj x n_j]       matrix with the cost for all the
%                               optimizations. 
%       weights [n_j x N_obj]   matrix with the weights forall the
%                               optimizations.
%       sim_r(h) [n_t x n_j]    matrxi with the trajectory of
%                               release(level) of all the optimizations.

ddpsol(size(weights,1)) = struct('J', [], 'weight', [], 'flag_vr', [], 'flag_ref', [], ...
    'sim_r', [], 'sim_h', []);

for idx = 1:length(ddpsol)
    ddpsol(idx).J       = JJJ(:,idx)';
    ddpsol(idx).weight  = weights(idx,:);
    ddpsol(idx).flag_vr = speed_constraint_check(sim_r(:,idx), sim_h(1:end-1,idx) );
    ddpsol(idx).flag_ref= 0;
    ddpsol(idx).sim_r   = sim_r(:,idx);
    ddpsol(idx).sim_h   = sim_h(:,idx);
end
clear JJJ weights sim_r sim_h
%% save to a file JJJ
fid = fopen( fullfile( raw_data_root, 'ddp_trajectories_99_18', 'ddpComo.txt'), 'w' );
fprintf( fid, '%d %d %d\n', cat(1, ddpsol.J)');
fclose(fid);
clear fid
%% extract reference set to another file
cmd = ['java -classpath ', fullfile('~/Documents/LakeComo_EMODPS/MOEAFramework/MOEAFramework-1.17-Executable.jar'), ...
    ' org.moeaframework.util.ReferenceSetMerger -e ', num2str([0.025, 1, 0.0025], '%d,%d,%d'),...
    ' -o ', fullfile( raw_data_root, 'ddp_trajectories_99_18', 'ddpComo.reference'), ' ', ...
    fullfile( raw_data_root, 'ddp_trajectories_99_18', 'ddpComo.txt') ];

system( cmd );
clear cmd
%% reload the file of the reference
ddpComoRef = load( fullfile( raw_data_root, 'ddp_trajectories_99_18', 'ddpComo.reference'), '-ascii' );
%ddpComoRef(ddpComoRef(:,1)>4.45, :) = [];
%% set the reference flag by comparing reference file and JJJ
for idx = 1:size(ddpComoRef, 1)
    
    diff_sol = cat(1, ddpsol.J) - ddpComoRef(idx, :);
    diff_sol = vecnorm( diff_sol' );
    [~, jdx] = min( diff_sol );
    
    ddpsol(jdx).flag_ref = idx;
end
clear idx jdx diff_sol ddpComoRef