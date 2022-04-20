% ddp_sol_format

% check no solution gives the same point in the sol space
% [JJJ_unique, ~, ic] = unique( JJJ', 'rows', 'stable');
% if any(~(ic==(1:length(JJJ))'))
%     JJJ == 

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
    ' org.moeaframework.util.ReferenceSetMerger -e ', num2str([0.025, 0.1, 0.025], '%d,%d,%d'),...
    ' -o ', fullfile( raw_data_root, 'ddp_trajectories_99_18', 'ddpComo.reference'), ' ', ...
    fullfile( raw_data_root, 'ddp_trajectories_99_18', 'ddpComo.txt') ];

system( cmd );
clear cmd
%% reload the file of the reference
ddpComoRef = load( fullfile( raw_data_root, 'ddp_trajectories_99_18', 'ddpComo.reference'), '-ascii' );

%% set the reference flag by comparing reference file and JJJ
for idx = 1:size(ddpComoRef, 1)
    
    diff_sol = cat(1, ddpsol.J) - ddpComoRef(idx, :);
    diff_sol = vecnorm( diff_sol' );
    [~, jdx] = min( diff_sol );
    
    ddpsol(jdx).flag_ref = idx;
end
clear idx jdx diff_sol ddpComoRef